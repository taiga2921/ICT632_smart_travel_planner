const locationService = require('../services/locationService');
const { success, error } = require('../utils/responseHelper');

const getCountries = async (req, res, next) => {
  try {
    if (!process.env.CSC_API_KEY) {
      return error(res, 'CSC_API_KEY is not configured on the server', 500);
    }

    const countries = await locationService.getCountries();
    return success(res, countries, 'Countries retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const getStates = async (req, res, next) => {
  try {
    if (!process.env.CSC_API_KEY) {
      return error(res, 'CSC_API_KEY is not configured on the server', 500);
    }

    const states = await locationService.getStates(req.params.ciso);
    return success(res, states, 'States retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const getCities = async (req, res, next) => {
  try {
    if (!process.env.CSC_API_KEY) {
      return error(res, 'CSC_API_KEY is not configured on the server', 500);
    }

    const cities = await locationService.getCities(req.params.ciso, req.params.siso);
    return success(res, cities, 'Cities retrieved successfully');
  } catch (err) {
    next(err);
  }
};

module.exports = { getCountries, getStates, getCities };
