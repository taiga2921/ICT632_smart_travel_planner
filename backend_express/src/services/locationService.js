const axios = require('axios');

const CSC_BASE_URL = 'https://api.countrystatecity.in/v1';

const request = async (path) => {
  const response = await axios.get(`${CSC_BASE_URL}${path}`, {
    headers: {
      'X-CSCAPI-KEY': process.env.CSC_API_KEY,
    },
  });
  return response.data;
};

const getCountries = async () => request('/countries');

const getStates = async (ciso) =>
  request(`/countries/${encodeURIComponent(ciso)}/states`);

const getCities = async (ciso, siso) =>
  request(
    `/countries/${encodeURIComponent(ciso)}/states/${encodeURIComponent(siso)}/cities`
  );

module.exports = { getCountries, getStates, getCities };
