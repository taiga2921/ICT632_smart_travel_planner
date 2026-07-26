const express = require('express');
const router = express.Router();
const restaurantController = require('../controllers/restaurantController');
const firebaseAuthMiddleware = require('../middleware/firebaseAuthMiddleware');

router.get('/', firebaseAuthMiddleware, restaurantController.searchRestaurants);

module.exports = router;
