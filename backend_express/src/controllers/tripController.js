const tripModel = require('../models/tripModel');
const userModel = require('../models/userModel');
const { success, created, error } = require('../utils/responseHelper');

const getAllTrips = async (req, res, next) => {
  try {
    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user) {
      return error(res, 'User not found', 404);
    }

    const trips = await tripModel.findAllByUserId(user.id);
    return success(res, trips, 'Trips retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const getTripById = async (req, res, next) => {
  try {
    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user) {
      return error(res, 'User not found', 404);
    }

    const trip = await tripModel.findById(req.params.id, user.id);

    if (!trip) {
      return error(res, 'Trip not found', 404);
    }

    return success(res, trip, 'Trip retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const createTrip = async (req, res, next) => {
  try {
    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user) {
      return error(res, 'User not found', 404);
    }

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

    const tripId = await tripModel.create({
      userId: user.id,
      destinationId,
      title,
      destinationName,
      startDate,
      endDate,
      budget,
      currency,
      notes,
    });

    const trip = await tripModel.findById(tripId, user.id);
    return created(res, trip, 'Trip created successfully');
  } catch (err) {
    next(err);
  }
};

const updateTrip = async (req, res, next) => {
  try {
    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user) {
      return error(res, 'User not found', 404);
    }

    const existing = await tripModel.findById(req.params.id, user.id);

    if (!existing) {
      return error(res, 'Trip not found', 404);
    }

    const {
      title,
      destinationName,
      startDate,
      endDate,
      budget,
      currency,
      notes,
      status,
    } = req.body;

    await tripModel.update(req.params.id, user.id, {
      title: title ?? existing.title,
      destinationName: destinationName ?? existing.destination_name,
      startDate: startDate ?? existing.start_date,
      endDate: endDate ?? existing.end_date,
      budget: budget ?? existing.budget,
      currency: currency ?? existing.currency,
      notes: notes ?? existing.notes,
      status: status ?? existing.status,
    });

    const trip = await tripModel.findById(req.params.id, user.id);
    return success(res, trip, 'Trip updated successfully');
  } catch (err) {
    next(err);
  }
};

const deleteTrip = async (req, res, next) => {
  try {
    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user) {
      return error(res, 'User not found', 404);
    }

    const affectedRows = await tripModel.remove(req.params.id, user.id);

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
