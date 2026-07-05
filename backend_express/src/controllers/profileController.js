const userModel = require('../models/userModel');
const { success } = require('../utils/responseHelper');

const getProfile = async (req, res, next) => {
  try {
    return success(res, req.user, 'Profile retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const updateProfile = async (req, res, next) => {
  try {
    const { name } = req.body;
    if (!name || name.trim() === '') {
      return res.status(422).json({
        success: false,
        message: 'Name is required',
      });
    }
    const updatedUser = await userModel.updateById(req.user.id, name.trim());
    return success(res, updatedUser, 'Profile updated successfully');
  } catch (err) {
    next(err);
  }
};

module.exports = { getProfile, updateProfile };
