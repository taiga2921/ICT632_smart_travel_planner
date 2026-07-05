const { getWeatherForecast } = require('../services/weatherService');
const { success, error } = require('../utils/responseHelper');

const getWeather = async (req, res, next) => {
  try {
    const { lat, lon } = req.query;

    if (!lat || !lon) {
      return error(res, 'lat and lon query parameters are required', 422);
    }

    const weather = await getWeatherForecast(lat, lon);
    return success(res, weather, 'Weather forecast retrieved successfully');
  } catch (err) {
    next(err);
  }
};

module.exports = { getWeather };
