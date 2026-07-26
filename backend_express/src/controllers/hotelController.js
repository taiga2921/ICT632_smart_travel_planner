const hotelService = require('../services/hotelService');
const { success, error } = require('../utils/responseHelper');

const formatDate = (date) => date.toISOString().slice(0, 10);

const searchHotels = async (req, res, next) => {
  try {
    const { query, check_in: checkInParam, check_out: checkOutParam } = req.query;

    if (!query) {
      return error(res, 'query query parameter is required', 422);
    }

    const today = new Date();
    const tomorrow = new Date(today.getTime() + 24 * 60 * 60 * 1000);

    const checkIn = checkInParam || formatDate(today);
    const checkOut = checkOutParam || formatDate(tomorrow);

    const hotels = await hotelService.searchHotels(query, checkIn, checkOut);
    return success(res, hotels, 'Hotels retrieved successfully');
  } catch (err) {
    next(err);
  }
};

module.exports = { searchHotels };
