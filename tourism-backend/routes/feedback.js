const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');

const db = require('../db').promise();

// ============================
// TEMP TOKEN STORAGE
// ============================
const feedbackTokens = {};

const TOKEN_EXPIRE_MS = 15 * 60 * 1000; // 15 min

// ============================
// CREATE TOKEN
// ============================
router.post('/create', async (req, res) => {
  const { visitor_id } = req.body;

  if (!visitor_id) {
    return res.status(400).json({
      message: 'visitor_id required'
    });
  }

  try {
    const [rows] = await db.query(
      `SELECT session_id, rating
       FROM session
       WHERE visitor_id=?
       ORDER BY session_id DESC
       LIMIT 1`,
      [visitor_id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        message: 'No session found for visitor'
      });
    }

    if (rows[0].rating !== null) {
      return res.status(400).json({
        message: 'Already rated'
      });
    }

    const token = uuidv4();

    feedbackTokens[token] = {
      visitor_id,
      createdAt: Date.now()
    };

    // =============================
    // 🔥 TERMINAL LOG HERE
    // =============================
  console.log('----------------------------------');
console.log('⭐ FEEDBACK TOKEN CREATED');
console.log('Visitor ID:', visitor_id);
console.log('Session ID:', rows[0].session_id);
console.log('TOKEN:', token);
console.log('OPEN LINK:');
console.log(`http://localhost:3000/feedback.html?token=${token}`);
console.log('----------------------------------');


    res.json({ token });

  } catch (err) {
    console.error('CREATE TOKEN ERROR:', err);
    res.status(500).json({
      message: 'Failed to create token'
    });
  }
});

// ============================
// VERIFY TOKEN (QR OPEN)
// ============================
router.get('/:token', (req, res) => {
  const { token } = req.params;

  const data = feedbackTokens[token];

  if (!data) {
    return res.status(404).json({
      message: 'Invalid token'
    });
  }

  // expiry check
  if (Date.now() - data.createdAt > TOKEN_EXPIRE_MS) {
    delete feedbackTokens[token];
    return res.status(400).json({
      message: 'Token expired'
    });
  }

  console.log("✅ TOKEN VERIFIED:", token);

  res.json({
    visitor_id: data.visitor_id
  });
});


// ============================
// SUBMIT FEEDBACK
// ============================
router.post('/submit', async (req, res) => {
  const { token, rating, feedback } = req.body;

  if (!token || !rating) {
    return res.status(400).json({
      message: 'token and rating required'
    });
  }

  const data = feedbackTokens[token];
  if (!data) {
    return res.status(400).json({
      message: 'Invalid token'
    });
  }

  try {
    await db.query(
      `UPDATE session
       SET rating=?, feedback=?, session_end=NOW()
       WHERE visitor_id=?
       ORDER BY session_id DESC
       LIMIT 1`,
      [rating, feedback || null, data.visitor_id]
    );

    delete feedbackTokens[token];

    console.log('FEEDBACK SAVED FOR:', data.visitor_id);

    res.json({ message: 'Feedback saved' });

  } catch (err) {
    console.error(err);
    res.status(500).json({
      message: 'Server error'
    });
  }
});

module.exports = router;
