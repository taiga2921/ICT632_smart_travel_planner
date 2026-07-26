const express = require('express');
const router = express.Router();
const geocodeController = require('../controllers/geocodeController');
const firebaseAuthMiddleware = require('../middleware/firebaseAuthMiddleware');

router.get('/', firebaseAuthMiddleware, geocodeController.getCoordinates);

module.exports = router;
