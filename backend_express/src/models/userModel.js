const pool = require('../config/db');

const findByFirebaseUid = async (firebaseUid) => {
  const [rows] = await pool.query(
    'SELECT * FROM users WHERE firebase_uid = ?',
    [firebaseUid]
  );
  return rows[0] || null;
};

const findOrCreate = async (firebaseUid, name, email) => {
  let user = await findByFirebaseUid(firebaseUid);
  if (!user) {
    await pool.query(
      'INSERT INTO users (firebase_uid, name, email, role) VALUES (?, ?, ?, ?)',
      [firebaseUid, name || email, email, 'user']
    );
    user = await findByFirebaseUid(firebaseUid);
  }
  return user;
};

const findById = async (id) => {
  const [rows] = await pool.query(
    'SELECT * FROM users WHERE id = ?',
    [id]
  );
  return rows[0] || null;
};

const updateById = async (id, name) => {
  await pool.query(
    'UPDATE users SET name = ? WHERE id = ?',
    [name, id]
  );
  return findById(id);
};

const findAll = async () => {
  const [rows] = await pool.query(
    'SELECT id, firebase_uid, name, email, role, created_at, updated_at FROM users ORDER BY created_at DESC'
  );
  return rows;
};

module.exports = { findByFirebaseUid, findOrCreate, findById, updateById, findAll };
