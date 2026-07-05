const userModel = require('../models/userModel');
const { success, error } = require('../utils/responseHelper');

const getProfile = async (req, res, next) => {
  try {
    const name = req.user.name || req.body.name || 'User';
    const email = req.user.email;

    if (!email) {
      return error(res, 'Email not found in token', 400);
    }

    const user = await userModel.findOrCreate(req.user.uid, name, email);
    return success(res, user, 'Profile retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const updateProfile = async (req, res, next) => {
  try {
    const { name } = req.body;

    if (!name) {
      return error(res, 'Name is required', 422);
    }

    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user) {
      return error(res, 'User not found', 404);
    }

    await userModel.update(user.id, { name });
    const updatedUser = await userModel.findByFirebaseUid(req.user.uid);
    return success(res, updatedUser, 'Profile updated successfully');
  } catch (err) {
    next(err);
  }
};

module.exports = { getProfile, updateProfile };
