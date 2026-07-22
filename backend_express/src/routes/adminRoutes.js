const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const firebaseAuthMiddleware = require('../middleware/firebaseAuthMiddleware');
const adminMiddleware = require('../middleware/adminMiddleware');

router.get('/users', firebaseAuthMiddleware, adminMiddleware, adminController.getAllUsers);
router.get('/trips', firebaseAuthMiddleware, adminMiddleware, adminController.getAllTrips);
router.delete('/trips/:id', firebaseAuthMiddleware, adminMiddleware, adminController.deleteTrip);

module.exports = router;
