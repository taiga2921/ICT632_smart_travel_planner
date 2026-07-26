const axios = require('axios');

const getAttractions = async (query, location) => {
  const response = await axios.get('https://serpapi.com/search', {
    params: {
      engine: 'google_local',
      q: query || `tourist attractions in ${location}`,
      location: location,
      hl: 'en',
      gl: 'my',
      api_key: process.env.SERPAPI_KEY,
    },
  });
  return response.data.local_results || [];
};

module.exports = { getAttractions };
