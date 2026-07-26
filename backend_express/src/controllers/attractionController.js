const attractionService = require('../services/attractionService');
const { success, error } = require('../utils/responseHelper');

const getAttractions = async (req, res, next) => {
  try {
    const { query, location } = req.query;

    if (!location) {
      return error(res, 'location query parameter is required', 422);
    }

    const attractions = await attractionService.getAttractions(query, location);
    return success(res, attractions, 'Attractions retrieved successfully');
  } catch (err) {
    next(err);
  }
};

module.exports = { getAttractions };
