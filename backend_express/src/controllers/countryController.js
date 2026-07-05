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
    next(err);
  }
};

module.exports = { getCountryInfo };
