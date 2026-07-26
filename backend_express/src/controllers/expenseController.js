const expenseModel = require('../models/expenseModel');
const tripModel = require('../models/tripModel');
const { pick } = require('../utils/requestHelper');
const { success, created, error } = require('../utils/responseHelper');

const getExpensesByTrip = async (req, res, next) => {
  try {
    const trip = await tripModel.findById(req.params.tripId, req.user.id);

    if (!trip) {
      return error(res, 'Trip not found', 404);
    }

    const expenses = await expenseModel.findAllByTripId(req.params.tripId, req.user.id);
    return success(res, expenses, 'Expenses retrieved successfully');
  } catch (err) {
    next(err);
  }
};

const createExpense = async (req, res, next) => {
  try {
    const trip = await tripModel.findById(req.params.tripId, req.user.id);

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

    const expense = await expenseModel.findById(expenseId, req.user.id);
    return created(res, expense, 'Expense created successfully');
  } catch (err) {
    next(err);
  }
};

const updateExpense = async (req, res, next) => {
  try {
    const existing = await expenseModel.findById(req.params.id, req.user.id);

    if (!existing) {
      return error(res, 'Expense not found', 404);
    }

    await expenseModel.update(req.params.id, req.user.id, {
      title: req.body.title ?? existing.title,
      amount: req.body.amount ?? existing.amount,
      currency: req.body.currency ?? existing.currency,
      category: req.body.category ?? existing.category,
      expenseDate: req.body.expenseDate ?? existing.expense_date,
      notes: pick(req.body, 'notes', existing.notes),
    });

    const expense = await expenseModel.findById(req.params.id, req.user.id);
    return success(res, expense, 'Expense updated successfully');
  } catch (err) {
    next(err);
  }
};

const deleteExpense = async (req, res, next) => {
  try {
    const affectedRows = await expenseModel.remove(req.params.id, req.user.id);

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
