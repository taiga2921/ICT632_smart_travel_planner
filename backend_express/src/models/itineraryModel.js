const pool = require('../config/db');

const findAllByTripId = async (tripId, userId) => {
  const [rows] = await pool.query(
    `SELECT i.* FROM itineraries i
     JOIN trips t ON i.trip_id = t.id
     WHERE i.trip_id = ? AND t.user_id = ?
     ORDER BY i.date ASC`,
    [tripId, userId]
  );
  return rows;
};

const findById = async (id, userId) => {
  const [rows] = await pool.query(
    `SELECT i.* FROM itineraries i
     JOIN trips t ON i.trip_id = t.id
     WHERE i.id = ? AND t.user_id = ?`,
    [id, userId]
  );
  return rows[0] || null;
};

const create = async (data) => {
  const { tripId, date, title, notes } = data;
  const [result] = await pool.query(
    'INSERT INTO itineraries (trip_id, date, title, notes) VALUES (?, ?, ?, ?)',
    [tripId, date, title || null, notes || null]
  );
  return result.insertId;
};

const update = async (id, userId, data) => {
  const { date, title, notes } = data;
  const [result] = await pool.query(
    `UPDATE itineraries i
     JOIN trips t ON i.trip_id = t.id
     SET i.date = ?, i.title = ?, i.notes = ?
     WHERE i.id = ? AND t.user_id = ?`,
    [date, title, notes, id, userId]
  );
  return result.affectedRows;
};

const remove = async (id, userId) => {
  const [result] = await pool.query(
    `DELETE i FROM itineraries i
     JOIN trips t ON i.trip_id = t.id
     WHERE i.id = ? AND t.user_id = ?`,
    [id, userId]
  );
  return result.affectedRows;
};

module.exports = { findAllByTripId, findById, create, update, remove };
