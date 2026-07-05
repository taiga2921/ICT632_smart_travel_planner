const express = require('express');
const router = express.Router();
const tripController = require('../controllers/tripController');
const itineraryController = require('../controllers/itineraryController');
const expenseController = require('../controllers/expenseController');
const firebaseAuthMiddleware = require('../middleware/firebaseAuthMiddleware');
const { validateRequired } = require('../middleware/validateMiddleware');

router.get('/', firebaseAuthMiddleware, tripController.getAllTrips);
router.post(
  '/',
  firebaseAuthMiddleware,
  validateRequired(['title', 'startDate', 'endDate']),
  tripController.createTrip
);
router.get('/:id', firebaseAuthMiddleware, tripController.getTripById);
router.put('/:id', firebaseAuthMiddleware, tripController.updateTrip);
router.delete('/:id', firebaseAuthMiddleware, tripController.deleteTrip);

router.get(
  '/:tripId/itineraries',
  firebaseAuthMiddleware,
  itineraryController.getItinerariesByTrip
);
router.post(
  '/:tripId/itineraries',
  firebaseAuthMiddleware,
  validateRequired(['date']),
  itineraryController.createItinerary
);

router.get(
  '/:tripId/expenses',
  firebaseAuthMiddleware,
  expenseController.getExpensesByTrip
);
router.post(
  '/:tripId/expenses',
  firebaseAuthMiddleware,
  validateRequired(['title', 'amount', 'expenseDate']),
  expenseController.createExpense
);

module.exports = router;
