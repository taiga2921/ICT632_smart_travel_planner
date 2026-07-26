const itineraryModel = require('../models/itineraryModel');
const tripModel = require('../models/tripModel');
const { pick } = require('../utils/requestHelper');
const { success, created, error } = require('../utils/responseHelper');

const getItinerariesByTrip = async (req, res, next) => {
  try {
    const trip = await tripModel.findById(req.params.tripId, req.user.id);

    if (!trip) {
      return error(res, 'Trip not found', 404);
    }

    const itineraries = await itineraryModel.findAllByTripId(req.params.tripId, req.user.id);
    return success(res, itineraries, 'Itineraries retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const createItinerary = async (req, res, next) => {
  try {
    const trip = await tripModel.findById(req.params.tripId, req.user.id);

    if (!trip) {
      return error(res, 'Trip not found', 404);
    }

    const { date, title, notes } = req.body;

    const itineraryId = await itineraryModel.create({
      tripId: req.params.tripId,
      date,
      title,
      notes,
    });

    const itinerary = await itineraryModel.findById(itineraryId, req.user.id);
    return created(res, itinerary, 'Itinerary created successfully');
  } catch (err) {
    next(err);
  }
};

const updateItinerary = async (req, res, next) => {
  try {
    const existing = await itineraryModel.findById(req.params.id, req.user.id);

    if (!existing) {
      return error(res, 'Itinerary not found', 404);
    }

    await itineraryModel.update(req.params.id, req.user.id, {
      date: req.body.date ?? existing.date,
      title: pick(req.body, 'title', existing.title),
      notes: pick(req.body, 'notes', existing.notes),
    });

    const itinerary = await itineraryModel.findById(req.params.id, req.user.id);
    return success(res, itinerary, 'Itinerary updated successfully');
  } catch (err) {
    next(err);
  }
};

const deleteItinerary = async (req, res, next) => {
  try {
    const affectedRows = await itineraryModel.remove(req.params.id, req.user.id);

    if (!affectedRows) {
      return error(res, 'Itinerary not found', 404);
    }

    return success(res, null, 'Itinerary deleted successfully');
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getItinerariesByTrip,
  createItinerary,
  updateItinerary,
  deleteItinerary,
};
