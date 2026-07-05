const expenseModel = require('../models/expenseModel');
const tripModel = require('../models/tripModel');
const userModel = require('../models/userModel');
const { success, created, error } = require('../utils/responseHelper');

const getExpensesByTrip = async (req, res, next) => {
  try {
    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user) {
      return error(res, 'User not found', 404);
    }

    const trip = await tripModel.findById(req.params.tripId, user.id);

    if (!trip) {
      return error(res, 'Trip not found', 404);
    }

    const expenses = await expenseModel.findAllByTripId(req.params.tripId, user.id);
    return success(res, expenses, 'Expenses retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const createExpense = async (req, res, next) => {
  try {
    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user) {
      return error(res, 'User not found', 404);
    }

    const trip = await tripModel.findById(req.params.tripId, user.id);

    if (!trip) {
      return error(res, 'Trip not found', 404);
    }

    const { title, amount, currency, category, expenseDate, notes } = req.body;

    const expenseId = await expenseModel.create({
      tripId: req.params.tripId,
      title,
      amount,
      currency,
      category,
      expenseDate,
      notes,
    });

    const expense = await expenseModel.findById(expenseId, user.id);
    return created(res, expense, 'Expense created successfully');
  } catch (err) {
    next(err);
  }
};

const updateExpense = async (req, res, next) => {
  try {
    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user) {
      return error(res, 'User not found', 404);
    }

    const existing = await expenseModel.findById(req.params.id, user.id);

    if (!existing) {
      return error(res, 'Expense not found', 404);
    }

    const { title, amount, currency, category, expenseDate, notes } = req.body;

    await expenseModel.update(req.params.id, user.id, {
      title: title ?? existing.title,
      amount: amount ?? existing.amount,
      currency: currency ?? existing.currency,
      category: category ?? existing.category,
      expenseDate: expenseDate ?? existing.expense_date,
      notes: notes ?? existing.notes,
    });

    const expense = await expenseModel.findById(req.params.id, user.id);
    return success(res, expense, 'Expense updated successfully');
  } catch (err) {
    next(err);
  }
};

const deleteExpense = async (req, res, next) => {
  try {
    const user = await userModel.findByFirebaseUid(req.user.uid);

    if (!user) {
      return error(res, 'User not found', 404);
    }

    const affectedRows = await expenseModel.remove(req.params.id, user.id);

    if (!affectedRows) {
      return error(res, 'Expense not found', 404);
    }

    return success(res, null, 'Expense deleted successfully');
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getExpensesByTrip,
  createExpense,
  updateExpense,
  deleteExpense,
};
