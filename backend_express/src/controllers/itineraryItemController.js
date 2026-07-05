const itineraryItemModel = require('../models/itineraryItemModel');
const userModel = require('../models/userModel');
const { success, created, error } = require('../utils/responseHelper');

const createItineraryItem = async (req, res, next) => {
  try {
    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user) {
      return error(res, 'User not found', 404);
    }

    const itinerary = await itineraryItemModel.verifyItineraryOwnership(
      req.params.itineraryId,
      user.id
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

    const item = await itineraryItemModel.findById(itemId, user.id);
    return created(res, item, 'Itinerary item created successfully');
  } catch (err) {
    next(err);
  }
};

const updateItineraryItem = async (req, res, next) => {
  try {
    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user) {
      return error(res, 'User not found', 404);
    }

    const existing = await itineraryItemModel.findById(req.params.id, user.id);

    if (!existing) {
      return error(res, 'Itinerary item not found', 404);
    }

    const { title, description, location, startTime, endTime, type } = req.body;

    await itineraryItemModel.update(req.params.id, user.id, {
      title: title ?? existing.title,
      description: description ?? existing.description,
      location: location ?? existing.location,
      startTime: startTime ?? existing.start_time,
      endTime: endTime ?? existing.end_time,
      type: type ?? existing.type,
    });

    const item = await itineraryItemModel.findById(req.params.id, user.id);
    return success(res, item, 'Itinerary item updated successfully');
  } catch (err) {
    next(err);
  }
};

const deleteItineraryItem = async (req, res, next) => {
  try {
    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user) {
      return error(res, 'User not found', 404);
    }

    const affectedRows = await itineraryItemModel.remove(req.params.id, user.id);

    if (!affectedRows) {
      return error(res, 'Itinerary item not found', 404);
    }

    return success(res, null, 'Itinerary item deleted successfully');
  } catch (err) {
    next(err);
  }
};

module.exports = {
  createItineraryItem,
  updateItineraryItem,
  deleteItineraryItem,
};
