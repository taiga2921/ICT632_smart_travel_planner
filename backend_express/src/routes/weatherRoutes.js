const express = require('express');
const router = express.Router();
const weatherController = require('../controllers/weatherController');
const firebaseAuthMiddleware = require('../middleware/firebaseAuthMiddleware');

router.get('/', firebaseAuthMiddleware, weatherController.getWeather);

module.exports = router;
