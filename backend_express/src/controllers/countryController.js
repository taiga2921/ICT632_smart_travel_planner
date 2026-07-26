const countryService = require('../services/countryService');
const { success, error } = require('../utils/responseHelper');

const getCountryInfo = async (req, res, next) => {
  try {
    const { name } = req.query;

    if (!name) {
      return error(res, 'name query parameter is required', 422);
    }

    const country = await countryService.getCountryInfo(name);
    return success(res, country, 'Country info retrieved successfully');
  } catch (err) {
    // RestCountries answers 404 for an unknown name, and the service throws
    // when the payload is empty. Both mean "no such country", not a server bug.
    if (err.response?.status === 404 || err.message?.startsWith('Country not found')) {
      return error(res, `Country not found: ${req.query.name}`, 404);
    }
    next(err);
  }
};

module.exports = { getCountryInfo };
