const axios = require('axios');

const searchRestaurants = async (query, location) => {
  const response = await axios.get('https://serpapi.com/search', {
    params: {
      engine: 'google_local',
      q: query || `restaurants in ${location}`,
      location: location,
      hl: 'en',
      gl: 'my',
      api_key: process.env.SERPAPI_KEY,
    },
  });
  return response.data.local_results || [];
};

module.exports = { searchRestaurants };
