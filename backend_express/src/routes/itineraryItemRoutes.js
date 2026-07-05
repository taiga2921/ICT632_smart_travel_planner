const express = require('express');
const router = express.Router();
const itineraryItemController = require('../controllers/itineraryItemController');
const firebaseAuthMiddleware = require('../middleware/firebaseAuthMiddleware');

router.put('/:id', firebaseAuthMiddleware, itineraryItemController.updateItineraryItem);
router.delete('/:id', firebaseAuthMiddleware, itineraryItemController.deleteItineraryItem);

module.exports = router;
