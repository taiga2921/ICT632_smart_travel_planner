const attractionService = require('../services/attractionService');
const { success, error } = require('../utils/responseHelper');

const getAttractions = async (req, res, next) => {
  try {
    const { lat, lon, radius } = req.query;

    if (!lat || !lon) {
      return error(res, 'lat and lon query parameters are required', 422);
    }

    const attractions = await attractionService.getAttractions(
      lat,
      lon,
      radius ? parseInt(radius, 10) : 5000
    );
    return success(res, attractions, 'Attractions retrieved successfully');
  } catch (err) {
    next(err);
  }
};

module.exports = { getAttractions };
