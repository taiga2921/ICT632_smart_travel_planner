const express = require('express');
const router = express.Router();
const hotelController = require('../controllers/hotelController');
const firebaseAuthMiddleware = require('../middleware/firebaseAuthMiddleware');

router.get('/', firebaseAuthMiddleware, hotelController.searchHotels);

module.exports = router;
