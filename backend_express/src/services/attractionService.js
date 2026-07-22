const axios = require('axios');

const getAttractions = async (lat, lon, radius = 5000, limit = 20) => {
  const response = await axios.get('https://api.opentripmap.com/0.1/en/places/radius', {
    params: {
      radius,
      lon,
      lat,
      limit,
      apikey: process.env.OPENTRIPMAP_API_KEY,
    },
  });
  return response.data.features || [];
};

module.exports = { getAttractions };
