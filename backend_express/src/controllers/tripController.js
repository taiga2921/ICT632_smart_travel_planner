const pool = require('../config/db');
const tripModel = require('../models/tripModel');
const { TRIP_STATUS } = require('../utils/constants');
const { pick } = require('../utils/requestHelper');
const { success, created, error } = require('../utils/responseHelper');

const VALID_STATUSES = Object.values(TRIP_STATUS);

/**
 * Reads a calendar date as local midnight. `new Date('2026-07-26')` is parsed as
 * UTC midnight, which lands on the previous calendar day for servers west of
 * Greenwich, so the components are pulled apart by hand instead.
 */
const INVALID_DATE = new Date(NaN);

const toLocalDate = (value) => {
  if (value instanceof Date) {
    return Number.isNaN(value.getTime())
      ? INVALID_DATE
      : new Date(value.getFullYear(), value.getMonth(), value.getDate());
  }

  // `new Date(null)` is the epoch rather than an invalid date, so blank input is
  // rejected before it reaches the Date constructor.
  if (value === null || value === undefined || value === '') return INVALID_DATE;

  const parts = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(value));
  if (parts) {
    return new Date(Number(parts[1]), Number(parts[2]) - 1, Number(parts[3]));
  }

  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) return INVALID_DATE;
  return new Date(parsed.getFullYear(), parsed.getMonth(), parsed.getDate());
};

const formatDate = (date) =>
  `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(
    date.getDate()
  ).padStart(2, '0')}`;

/**
 * Trip status is derived from today's date rather than read from the column, so
 * a trip moves from planned to ongoing to completed without anyone writing to
 * the database. The stored `status` column is left untouched.
 */
const computeStatus = (startDate, endDate) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const start = toLocalDate(startDate);
  const end = toLocalDate(endDate);

  if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
    return TRIP_STATUS.PLANNED;
  }

  if (today < start) return TRIP_STATUS.PLANNED;
  if (today > end) return TRIP_STATUS.COMPLETED;
  return TRIP_STATUS.ONGOING;
};

const withComputedStatus = (trip) => ({
  ...trip,
  status: computeStatus(trip.start_date, trip.end_date),
});

const eachDateInRange = (startDate, endDate) => {
  const start = toLocalDate(startDate);
  const end = toLocalDate(endDate);

  if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
    return [];
  }

  const dates = [];
  let dayNumber = 1;
  for (const d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
    dates.push({ dateStr: formatDate(d), dayNumber });
    dayNumber += 1;
  }
  return dates;
};

/**
 * Brings the trip's daily itinerary rows in line with its date range: drops the
 * days that fell out of the range and adds the ones that are now missing. Days
 * that survive the change keep their id, title, notes and items.
 *
 * `itineraries` has no unique key on (trip_id, date), so the existing days are
 * read first instead of relying on INSERT IGNORE to swallow duplicates.
 */
const syncItineraries = async (tripId, newStartDate, newEndDate) => {
  const dates = eachDateInRange(newStartDate, newEndDate);
  if (dates.length === 0) return;

  await pool.query(
    'DELETE FROM itineraries WHERE trip_id = ? AND (date < ? OR date > ?)',
    [tripId, dates[0].dateStr, dates[dates.length - 1].dateStr]
  );

  const [existingRows] = await pool.query(
    'SELECT date FROM itineraries WHERE trip_id = ?',
    [tripId]
  );
  const existingDates = new Set(existingRows.map((row) => String(row.date)));

  for (const { dateStr, dayNumber } of dates) {
    if (existingDates.has(dateStr)) continue;
    await pool.query(
      'INSERT IGNORE INTO itineraries (trip_id, date, title) VALUES (?, ?, ?)',
      [tripId, dateStr, `Day ${dayNumber}`]
    );
  }
};

const getAllTrips = async (req, res, next) => {
  try {
    const { status } = req.query;

    if (status && !VALID_STATUSES.includes(status)) {
      return error(res, `status must be one of: ${VALID_STATUSES.join(', ')}`, 422);
    }

    // Fetch every trip first: the filter runs against the computed status, not
    // the stored column, so it cannot be pushed down into SQL.
    const trips = await tripModel.findAllByUserId(req.user.id);
    const tripsWithStatus = trips.map(withComputedStatus);

    const filtered = status
      ? tripsWithStatus.filter((trip) => trip.status === status)
      : tripsWithStatus;

    return success(res, filtered, 'Trips retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const getTripById = async (req, res, next) => {
  try {
    const trip = await tripModel.findById(req.params.id, req.user.id);

    if (!trip) {
      return error(res, 'Trip not found', 404);
    }

    return success(res, withComputedStatus(trip), 'Trip retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const createTrip = async (req, res, next) => {
  try {
    const {
      title,
      destinationId,
      destinationName,
      startDate,
      endDate,
      budget,
      currency,
      notes,
    } = req.body;

    if (toLocalDate(endDate) < toLocalDate(startDate)) {
      return error(res, 'endDate must be on or after startDate', 422);
    }

    const tripId = await tripModel.create({
      userId: req.user.id,
      destinationId,
      title,
      destinationName,
      startDate,
      endDate,
      budget,
      currency,
      notes,
    });

    await syncItineraries(tripId, startDate, endDate);

    const trip = await tripModel.findById(tripId, req.user.id);
    return created(res, withComputedStatus(trip), 'Trip created successfully');
  } catch (err) {
    next(err);
  }
};

const updateTrip = async (req, res, next) => {
  try {
    const existing = await tripModel.findById(req.params.id, req.user.id);

    if (!existing) {
      return error(res, 'Trip not found', 404);
    }

    const { status } = req.body;

    if (status && !VALID_STATUSES.includes(status)) {
      return error(res, `status must be one of: ${VALID_STATUSES.join(', ')}`, 422);
    }

    const parsedStart = toLocalDate(req.body.startDate ?? existing.start_date);
    const parsedEnd = toLocalDate(req.body.endDate ?? existing.end_date);

    if (Number.isNaN(parsedStart.getTime()) || Number.isNaN(parsedEnd.getTime())) {
      return error(res, 'startDate and endDate must be valid YYYY-MM-DD dates', 422);
    }

    if (parsedEnd < parsedStart) {
      return error(res, 'endDate must be on or after startDate', 422);
    }

    // Normalise before comparing so an incoming ISO timestamp is not mistaken
    // for a date change against the YYYY-MM-DD value stored in MySQL.
    const newStartDate = formatDate(parsedStart);
    const newEndDate = formatDate(parsedEnd);
    const datesChanged =
      newStartDate !== formatDate(toLocalDate(existing.start_date)) ||
      newEndDate !== formatDate(toLocalDate(existing.end_date));

    await tripModel.update(req.params.id, req.user.id, {
      title: req.body.title ?? existing.title,
      destinationName: pick(req.body, 'destinationName', existing.destination_name),
      startDate: newStartDate,
      endDate: newEndDate,
      budget: req.body.budget ?? existing.budget,
      currency: req.body.currency ?? existing.currency,
      notes: pick(req.body, 'notes', existing.notes),
      status: existing.status, // stored status is ignored on read; computed instead
    });

    if (datesChanged) {
      await syncItineraries(req.params.id, newStartDate, newEndDate);
    }

    const trip = await tripModel.findById(req.params.id, req.user.id);
    return success(res, withComputedStatus(trip), 'Trip updated successfully');
  } catch (err) {
    next(err);
  }
};

const deleteTrip = async (req, res, next) => {
  try {
    const affectedRows = await tripModel.remove(req.params.id, req.user.id);

    if (!affectedRows) {
      return error(res, 'Trip not found', 404);
    }

    return success(res, null, 'Trip deleted successfully');
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getAllTrips,
  getTripById,
  createTrip,
  updateTrip,
  deleteTrip,
};
