const userModel = require('../models/userModel');
const { error } = require('../utils/responseHelper');

const adminMiddleware = async (req, res, next) => {
  try {
    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user || user.role !== 'admin') {
      return error(res, 'Forbidden: admin access required', 403);
    }

    req.dbUser = user;
    next();
  } catch (err) {
    next(err);
  }
};

module.exports = adminMiddleware;
