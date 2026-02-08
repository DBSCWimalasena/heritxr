// db.js
const mysql = require('mysql2');
const fs = require('fs');
const path = require('path');

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: 3306,
  ssl: {
    ca: fs.readFileSync(
      path.join(__dirname, 'certs', 'DigiCertGlobalRootG2.crt.pem')
    )
  },
  waitForConnections: true,
  connectionLimit: 10
});

// ✅ Test connection
pool.getConnection((err, conn) => {
  if (err) {
    console.error('❌ DB connection failed:', err);
  } else {
    console.log('✅ Connected to Azure MySQL');
    conn.release();
  }
});

module.exports = pool;
