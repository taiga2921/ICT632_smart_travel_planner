const axios = require('axios');

const searchHotels = async (query, checkIn, checkOut) => {
  const response = await axios.get('https://serpapi.com/search', {
    params: {
      engine: 'google_hotels',
      q: query,
      check_in_date: checkIn,
      check_out_date: checkOut,
      hl: 'en',
      gl: 'my',
      currency: 'MYR',
      api_key: process.env.SERPAPI_KEY,
    },
  });
  return response.data.properties || [];
};

module.exports = { searchHotels };
