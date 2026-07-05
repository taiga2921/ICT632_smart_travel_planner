const { error } = require('../utils/responseHelper');

const errorMiddleware = (err, req, res, next) => {
  console.error(err);
  return error(res, 'An error occurred', 500);
};

module.exports = errorMiddleware;
