const pool = require('../config/db');

const findAllByTripId = async (tripId, userId) => {
  const [rows] = await pool.query(
    `SELECT e.* FROM expenses e
     JOIN trips t ON e.trip_id = t.id
     WHERE e.trip_id = ? AND t.user_id = ?
     ORDER BY e.expense_date DESC`,
    [tripId, userId]
  );
  return rows;
};

const findById = async (id, userId) => {
  const [rows] = await pool.query(
    `SELECT e.* FROM expenses e
     JOIN trips t ON e.trip_id = t.id
     WHERE e.id = ? AND t.user_id = ?`,
    [id, userId]
  );
  return rows[0] || null;
};

const create = async (data) => {
  const { tripId, title, amount, currency, category, expenseDate, notes } = data;
  const [result] = await pool.query(
    `INSERT INTO expenses (trip_id, title, amount, currency, category, expense_date, notes)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [tripId, title, amount, currency || 'MYR', category || 'other', expenseDate, notes || null]
  );
  return result.insertId;
};

const update = async (id, userId, data) => {
  const { title, amount, currency, category, expenseDate, notes } = data;
  const [result] = await pool.query(
    `UPDATE expenses e
     JOIN trips t ON e.trip_id = t.id
     SET e.title = ?, e.amount = ?, e.currency = ?, e.category = ?,
         e.expense_date = ?, e.notes = ?
     WHERE e.id = ? AND t.user_id = ?`,
    [title, amount, currency, category, expenseDate, notes, id, userId]
  );
  return result.affectedRows;
};

const remove = async (id, userId) => {
  const [result] = await pool.query(
    `DELETE e FROM expenses e
     JOIN trips t ON e.trip_id = t.id
     WHERE e.id = ? AND t.user_id = ?`,
    [id, userId]
  );
  return result.affectedRows;
};

module.exports = { findAllByTripId, findById, create, update, remove };
