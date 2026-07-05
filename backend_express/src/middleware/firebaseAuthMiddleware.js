const admin = require('../config/firebase');
const { error } = require('../utils/responseHelper');

const firebaseAuthMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return error(res, 'Unauthorized: missing or invalid token', 401);
    }

    const token = authHeader.split('Bearer ')[1];
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (err) {
    return error(res, 'Unauthorized: invalid token', 401);
  }
};

module.exports = firebaseAuthMiddleware;
