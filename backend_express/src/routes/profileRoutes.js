const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');
const firebaseAuthMiddleware = require('../middleware/firebaseAuthMiddleware');

router.get('/', firebaseAuthMiddleware, profileController.getProfile);
router.put('/', firebaseAuthMiddleware, profileController.updateProfile);

module.exports = router;
