const express = require('express');
const router = express.Router();
const countryController = require('../controllers/countryController');
const firebaseAuthMiddleware = require('../middleware/firebaseAuthMiddleware');

router.get('/', firebaseAuthMiddleware, countryController.getCountryInfo);

module.exports = router;
