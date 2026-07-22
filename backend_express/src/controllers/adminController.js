const userModel = require('../models/userModel');
const tripModel = require('../models/tripModel');
const { success, error } = require('../utils/responseHelper');

const getAllUsers = async (req, res, next) => {
  try {
    const users = await userModel.findAll();
    return success(res, users, 'Users retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const getAllTrips = async (req, res, next) => {
  try {
    const trips = await tripModel.findAll();
    return success(res, trips, 'Trips retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const deleteTrip = async (req, res, next) => {
  try {
    const affectedRows = await tripModel.removeById(req.params.id);

    if (!affectedRows) {
      return error(res, 'Trip not found', 404);
    }

    return success(res, null, 'Trip deleted successfully');
  } catch (err) {
    next(err);
  }
};

module.exports = { getAllUsers, getAllTrips, deleteTrip };
