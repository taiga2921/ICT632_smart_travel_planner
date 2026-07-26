const axios = require('axios');

const getWeatherForecast = async (lat, lon) => {
  const response = await axios.get('https://api.open-meteo.com/v1/forecast', {
    params: {
      latitude: lat,
      longitude: lon,
      current_weather: true,
      daily: 'temperature_2m_max,temperature_2m_min,precipitation_sum,weathercode',
      timezone: 'auto',
      forecast_days: 7,
    },
  });
  return response.data;
};

module.exports = { getWeatherForecast };
