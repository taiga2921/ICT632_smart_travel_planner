const express = require('express');
const router = express.Router();
const locationController = require('../controllers/locationController');
const firebaseAuthMiddleware = require('../middleware/firebaseAuthMiddleware');

router.get('/countries', firebaseAuthMiddleware, locationController.getCountries);
router.get(
  '/countries/:ciso/states',
  firebaseAuthMiddleware,
  locationController.getStates
);
router.get(
  '/countries/:ciso/states/:siso/cities',
  firebaseAuthMiddleware,
  locationController.getCities
);

module.exports = router;
