const express = require('express');
const router = express.Router();
const itineraryController = require('../controllers/itineraryController');
const itineraryItemController = require('../controllers/itineraryItemController');
const firebaseAuthMiddleware = require('../middleware/firebaseAuthMiddleware');
const { validateRequired } = require('../middleware/validateMiddleware');

router.put('/:id', firebaseAuthMiddleware, itineraryController.updateItinerary);
router.delete('/:id', firebaseAuthMiddleware, itineraryController.deleteItinerary);

router.post(
  '/:itineraryId/items',
  firebaseAuthMiddleware,
  validateRequired(['title']),
  itineraryItemController.createItineraryItem
);

module.exports = router;
