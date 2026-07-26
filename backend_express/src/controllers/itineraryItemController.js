const itineraryItemModel = require('../models/itineraryItemModel');
const { pick } = require('../utils/requestHelper');
const { success, created, error } = require('../utils/responseHelper');

const getItemsByItinerary = async (req, res, next) => {
  try {
    const itinerary = await itineraryItemModel.verifyItineraryOwnership(
      req.params.itineraryId,
      req.user.id
    );

    if (!itinerary) {
      return error(res, 'Itinerary not found', 404);
    }

    const items = await itineraryItemModel.findAllByItineraryId(
      req.params.itineraryId,
      req.user.id
    );
    return success(res, items, 'Itinerary items retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const createItineraryItem = async (req, res, next) => {
  try {
    const itinerary = await itineraryItemModel.verifyItineraryOwnership(
      req.params.itineraryId,
      req.user.id
    );

    if (!itinerary) {
      return error(res, 'Itinerary not found', 404);
    }

    const { title, description, location, startTime, endTime, type } = req.body;

    const itemId = await itineraryItemModel.create({
      itineraryId: req.params.itineraryId,
      title,
      description,
      location,
      startTime,
      endTime,
      type,
    });

    const item = await itineraryItemModel.findById(itemId, req.user.id);
    return created(res, item, 'Itinerary item created successfully');
  } catch (err) {
    next(err);
  }
};

const updateItineraryItem = async (req, res, next) => {
  try {
    const existing = await itineraryItemModel.findById(req.params.id, req.user.id);

    if (!existing) {
      return error(res, 'Itinerary item not found', 404);
    }

    await itineraryItemModel.update(req.params.id, req.user.id, {
      title: req.body.title ?? existing.title,
      description: pick(req.body, 'description', existing.description),
      location: pick(req.body, 'location', existing.location),
      startTime: pick(req.body, 'startTime', existing.start_time),
      endTime: pick(req.body, 'endTime', existing.end_time),
      type: req.body.type ?? existing.type,
    });

    const item = await itineraryItemModel.findById(req.params.id, req.user.id);
    return success(res, item, 'Itinerary item updated successfully');
  } catch (err) {
    next(err);
  }
};

const deleteItineraryItem = async (req, res, next) => {
  try {
    const affectedRows = await itineraryItemModel.remove(req.params.id, req.user.id);

    if (!affectedRows) {
      return error(res, 'Itinerary item not found', 404);
    }

    return success(res, null, 'Itinerary item deleted successfully');
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getItemsByItinerary,
  createItineraryItem,
  updateItineraryItem,
  deleteItineraryItem,
};
