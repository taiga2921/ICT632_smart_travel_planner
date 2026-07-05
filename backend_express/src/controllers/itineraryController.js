const itineraryModel = require('../models/itineraryModel');
const tripModel = require('../models/tripModel');
const userModel = require('../models/userModel');
const { success, created, error } = require('../utils/responseHelper');

const getItinerariesByTrip = async (req, res, next) => {
  try {
    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user) {
      return error(res, 'User not found', 404);
    }

    const trip = await tripModel.findById(req.params.tripId, user.id);

    if (!trip) {
      return error(res, 'Trip not found', 404);
    }

    const itineraries = await itineraryModel.findAllByTripId(req.params.tripId, user.id);
    return success(res, itineraries, 'Itineraries retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const createItinerary = async (req, res, next) => {
  try {
    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user) {
      return error(res, 'User not found', 404);
    }

    const trip = await tripModel.findById(req.params.tripId, user.id);

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

    const itinerary = await itineraryModel.findById(itineraryId, user.id);
    return created(res, itinerary, 'Itinerary created successfully');
  } catch (err) {
    next(err);
  }
};

const updateItinerary = async (req, res, next) => {
  try {
    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user) {
      return error(res, 'User not found', 404);
    }

    const existing = await itineraryModel.findById(req.params.id, user.id);

    if (!existing) {
      return error(res, 'Itinerary not found', 404);
    }

    const { date, title, notes } = req.body;

    await itineraryModel.update(req.params.id, user.id, {
      date: date ?? existing.date,
      title: title ?? existing.title,
      notes: notes ?? existing.notes,
    });

    const itinerary = await itineraryModel.findById(req.params.id, user.id);
    return success(res, itinerary, 'Itinerary updated successfully');
  } catch (err) {
    next(err);
  }
};

const deleteItinerary = async (req, res, next) => {
  try {
    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user) {
      return error(res, 'User not found', 404);
    }

    const affectedRows = await itineraryModel.remove(req.params.id, user.id);

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
