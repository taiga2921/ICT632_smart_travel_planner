const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  waitForConnections: true,
  connectionLimit: 10,
  // Keep DATE/DATETIME as raw strings so the API emits `YYYY-MM-DD` instead of a
  // timezone-shifted ISO timestamp.
  dateStrings: ['DATE', 'DATETIME'],
});

module.exports = pool;
