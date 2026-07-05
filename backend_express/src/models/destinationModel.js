const pool = require('../config/db');

const findAll = async () => {
  const [rows] = await pool.query(
    'SELECT * FROM destinations ORDER BY name ASC'
  );
  return rows;
};

const findById = async (id) => {
  const [rows] = await pool.query(
    'SELECT * FROM destinations WHERE id = ?',
    [id]
  );
  return rows[0] || null;
};

module.exports = { findAll, findById };
