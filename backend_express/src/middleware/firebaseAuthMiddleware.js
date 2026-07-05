const admin = require('../config/firebase');
const userModel = require('../models/userModel');

const firebaseAuthMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized: No token provided',
      });
    }

    const token = authHeader.split('Bearer ')[1];
    const decodedToken = await admin.auth().verifyIdToken(token);

    const mysqlUser = await userModel.findOrCreate(
      decodedToken.uid,
      decodedToken.name || decodedToken.email,
      decodedToken.email
    );

    req.user = mysqlUser;

    next();
  } catch (err) {
    if (
      err.code === 'auth/id-token-expired' ||
      err.code === 'auth/argument-error' ||
      err.code === 'auth/id-token-revoked'
    ) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized: Invalid or expired token',
      });
    }
    next(err);
  }
};

module.exports = firebaseAuthMiddleware;
