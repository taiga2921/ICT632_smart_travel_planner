const restaurantService = require('../services/restaurantService');
const { success, error } = require('../utils/responseHelper');

const searchRestaurants = async (req, res, next) => {
  try {
    const { query, location } = req.query;

    if (!location) {
      return error(res, 'location query parameter is required', 422);
    }

    const restaurants = await restaurantService.searchRestaurants(query, location);
    return success(res, restaurants, 'Restaurants retrieved successfully');
  } catch (err) {
    next(err);
  }
};

module.exports = { searchRestaurants };
