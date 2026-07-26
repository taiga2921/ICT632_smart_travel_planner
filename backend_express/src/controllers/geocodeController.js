const { geocodeLocation } = require('../services/geocodeService');
const { success, error } = require('../utils/responseHelper');

const getCoordinates = async (req, res, next) => {
  try {
    const { location } = req.query;

    if (!location || String(location).trim() === '') {
      return error(res, 'location query parameter is required', 422);
    }

    const result = await geocodeLocation(String(location).trim());
    return success(res, result, 'Coordinates retrieved successfully');
  } catch (err) {
    if (err.message && err.message.startsWith('Location not found')) {
      return error(res, err.message, 404);
    }
    next(err);
  }
};

module.exports = { getCoordinates };
