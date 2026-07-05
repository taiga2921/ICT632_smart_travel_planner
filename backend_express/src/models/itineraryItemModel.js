const pool = require('../config/db');

const findById = async (id, userId) => {
  const [rows] = await pool.query(
    `SELECT ii.* FROM itinerary_items ii
     JOIN itineraries i ON ii.itinerary_id = i.id
     JOIN trips t ON i.trip_id = t.id
     WHERE ii.id = ? AND t.user_id = ?`,
    [id, userId]
  );
  return rows[0] || null;
};

const create = async (data) => {
  const { itineraryId, title, description, location, startTime, endTime, type } = data;
  const [result] = await pool.query(
    `INSERT INTO itinerary_items (itinerary_id, title, description, location, start_time, end_time, type)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [itineraryId, title, description || null, location || null, startTime || null, endTime || null, type || 'activity']
  );
  return result.insertId;
};

const update = async (id, userId, data) => {
  const { title, description, location, startTime, endTime, type } = data;
  const [result] = await pool.query(
    `UPDATE itinerary_items ii
     JOIN itineraries i ON ii.itinerary_id = i.id
     JOIN trips t ON i.trip_id = t.id
     SET ii.title = ?, ii.description = ?, ii.location = ?,
         ii.start_time = ?, ii.end_time = ?, ii.type = ?
     WHERE ii.id = ? AND t.user_id = ?`,
    [title, description, location, startTime, endTime, type, id, userId]
  );
  return result.affectedRows;
};

const remove = async (id, userId) => {
  const [result] = await pool.query(
    `DELETE ii FROM itinerary_items ii
     JOIN itineraries i ON ii.itinerary_id = i.id
     JOIN trips t ON i.trip_id = t.id
     WHERE ii.id = ? AND t.user_id = ?`,
    [id, userId]
  );
  return result.affectedRows;
};

const verifyItineraryOwnership = async (itineraryId, userId) => {
  const [rows] = await pool.query(
    `SELECT i.id FROM itineraries i
     JOIN trips t ON i.trip_id = t.id
     WHERE i.id = ? AND t.user_id = ?`,
    [itineraryId, userId]
  );
  return rows[0] || null;
};

module.exports = { findById, create, update, remove, verifyItineraryOwnership };
