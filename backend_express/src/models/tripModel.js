const pool = require('../config/db');

/**
 * Returns every trip for the user. Status filtering deliberately lives in the
 * controller because the status shown to clients is derived from the trip dates
 * rather than the stored column.
 */
const findAllByUserId = async (userId) => {
  const [rows] = await pool.query(
    'SELECT * FROM trips WHERE user_id = ? ORDER BY created_at DESC',
    [userId]
  );
  return rows;
};

const findById = async (id, userId) => {
  const [rows] = await pool.query(
    'SELECT * FROM trips WHERE id = ? AND user_id = ?',
    [id, userId]
  );
  return rows[0] || null;
};

const findByIdAdmin = async (id) => {
  const [rows] = await pool.query('SELECT * FROM trips WHERE id = ?', [id]);
  return rows[0] || null;
};

const create = async (data) => {
  const {
    userId,
    destinationId,
    title,
    destinationName,
    startDate,
    endDate,
    budget,
    currency,
    notes,
  } = data;
  const [result] = await pool.query(
    `INSERT INTO trips (user_id, destination_id, title, destination_name, start_date, end_date, budget, currency, notes)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [userId, destinationId || null, title, destinationName || null, startDate, endDate, budget || 0, currency || 'MYR', notes || null]
  );
  return result.insertId;
};

const update = async (id, userId, data) => {
  const {
    title,
    destinationName,
    startDate,
    endDate,
    budget,
    currency,
    notes,
    status,
  } = data;
  const [result] = await pool.query(
    `UPDATE trips SET title = ?, destination_name = ?, start_date = ?, end_date = ?,
     budget = ?, currency = ?, notes = ?, status = ? WHERE id = ? AND user_id = ?`,
    [title, destinationName, startDate, endDate, budget, currency, notes, status, id, userId]
  );
  return result.affectedRows;
};

const remove = async (id, userId) => {
  const [result] = await pool.query(
    'DELETE FROM trips WHERE id = ? AND user_id = ?',
    [id, userId]
  );
  return result.affectedRows;
};

const removeById = async (id) => {
  const [result] = await pool.query('DELETE FROM trips WHERE id = ?', [id]);
  return result.affectedRows;
};

const findAll = async () => {
  const [rows] = await pool.query(
    `SELECT t.*, u.name AS user_name, u.email AS user_email
     FROM trips t
     JOIN users u ON t.user_id = u.id
     ORDER BY t.created_at DESC`
  );
  return rows;
};

module.exports = {
  findAllByUserId,
  findById,
  findByIdAdmin,
  create,
  update,
  remove,
  removeById,
  findAll,
};
