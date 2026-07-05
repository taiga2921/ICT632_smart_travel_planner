const express = require('express');
const router = express.Router();
const attractionController = require('../controllers/attractionController');
const firebaseAuthMiddleware = require('../middleware/firebaseAuthMiddleware');

router.get('/', firebaseAuthMiddleware, attractionController.getAttractions);

module.exports = router;
