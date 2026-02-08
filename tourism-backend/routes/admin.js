const express = require('express');
const bcrypt = require('bcryptjs');
const router = express.Router();
const db = require('../db');

// =======================
// ADMIN REGISTER
// =======================
router.post('/register', (req, res) => {
  const { name, email, phone_numb, password } = req.body;

  console.log('REGISTER ROUTE HIT', req.body);

  if (!name || !email || !phone_numb || !password) {
    return res.status(400).json({
      message: 'All fields are required'
    });
  }

  // 1️⃣ Check if email already exists
  db.query(
    'SELECT admin_id FROM admin WHERE email = ?',
    [email],
    (err, results) => {

      if (err) {
        console.error('REGISTER EMAIL CHECK ERROR:', err);
        return res.status(500).json({
          message: 'Failed to register admin'
        });
      }

      if (results.length > 0) {
        return res.status(409).json({
          message: 'Email already exists'
        });
      }

      // 2️⃣ Hash password
      bcrypt.hash(password, 10, (err, hashedPassword) => {

        if (err) {
          console.error('BCRYPT HASH ERROR:', err);
          return res.status(500).json({
            message: 'Failed to register admin'
          });
        }

        // 3️⃣ Insert admin (CORRECT COLUMN NAME)
        db.query(
          `INSERT INTO admin (name, email, phone_number, password)
           VALUES (?, ?, ?, ?)`,
          [name, email, phone_numb, hashedPassword],
          (err, result) => {

            if (err) {
              console.error('REGISTER INSERT ERROR:', err);
              return res.status(500).json({
                message: 'Failed to register admin'
              });
            }

            // ✅ SUCCESS
            return res.status(201).json({
              message: 'Admin registered successfully'
            });
          }
        );
      });
    }
  );
});


// =======================
// ADMIN LOGIN
// =======================
router.post('/login', (req, res) => {
  const { email, password } = req.body;

  console.log('LOGIN ROUTE HIT', req.body);

  if (!email || !password) {
    return res.status(400).json({
      message: 'Email and password are required'
    });
  }

  db.query(
    'SELECT * FROM admin WHERE email = ?',
    [email],
    (err, results) => {

      if (err) {
        console.error('LOGIN DB ERROR:', err);
        return res.status(500).json({
          message: 'Login failed'
        });
      }

      if (results.length === 0) {
        return res.status(401).json({
          message: 'Invalid email or password'
        });
      }

      const admin = results[0];

      bcrypt.compare(password, admin.password, (err, isMatch) => {

        if (err) {
          console.error('BCRYPT ERROR:', err);
          return res.status(500).json({
            message: 'Login failed'
          });
        }

        if (!isMatch) {
          return res.status(401).json({
            message: 'Invalid email or password'
          });
        }

        // ✅ SUCCESS
        return res.status(200).json({
          message: 'Login successful',
          admin: {
            admin_id: admin.admin_id,
            name: admin.name,
            email: admin.email
          }
        });
      });
    }
  );
});

module.exports = router;
