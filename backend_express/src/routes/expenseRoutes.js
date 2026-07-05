const express = require('express');
const router = express.Router();
const expenseController = require('../controllers/expenseController');
const firebaseAuthMiddleware = require('../middleware/firebaseAuthMiddleware');

router.put('/:id', firebaseAuthMiddleware, expenseController.updateExpense);
router.delete('/:id', firebaseAuthMiddleware, expenseController.deleteExpense);

module.exports = router;
