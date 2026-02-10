const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');

// mysql2 promise wrapper
const db = require('../db').promise();

// ============================
// TEMP STORAGE (RAM) – QR FLOW
// ============================
const tempVisitors = {};

// 🔹 TEST TOKEN (optional)
tempVisitors['TEST123'] = {
  name: 'Local Test User',
  duration: 10,
  createdAt: Date.now()
};

// ============================
// CREATE TEMP VISITOR (QR STEP)
// ============================
router.post('/temp-create', (req, res) => {
  const { name, duration } = req.body;

  if (!name || !duration) {
    return res.status(400).json({
      message: 'Name and duration are required'
    });
  }

  const token = uuidv4();

  tempVisitors[token] = {
    name,
    duration,
    createdAt: Date.now()
  };

  // ⭐ LOG LINK
  console.log('==============================');
  console.log('📱 QR LINK GENERATED');
  console.log('Name:', name);
  console.log('Duration:', duration);
  console.log('TOKEN:', token);
  console.log(`OPEN: http://localhost:3000/api/visitor/temp/${token}`);
  console.log('==============================');

  res.json({ token });
});

// =================================
// GET TEMP VISITOR (QR OPEN)
// =================================
router.get('/temp/:token', (req, res) => {
  const { token } = req.params;

  console.log('TEMP FETCH REQUEST:', token);

  const visitor = tempVisitors[token];
  if (!visitor) {
    return res.status(404).json({ message: 'Invalid or expired QR' });
  }

  res.json({
    name: visitor.name,
    duration: visitor.duration
  });
});

// ============================
// FINAL SUBMIT (SAVE TO DB)
// ============================
router.post('/submit', async (req, res) => {
  const {
    token,
    age_group,
    visit_purpose,
    interest_architecture,
    interest_history,
    interest_spirituality,
    interest_art,
    visited_before,
    language_level,
    explanation_type,
    timeline_direction,
    preferred_time,
    buddhist_history_knowledge
  } = req.body;

  const temp = tempVisitors[token];
  if (!temp) {
    return res.status(400).json({ message: 'Invalid or expired token' });
  }

  try {
    // 🔢 Queue number
    const [rows] = await db.query(
      "SELECT COUNT(*) AS count FROM visitor WHERE status='waiting'"
    );
    const queueNumber = rows[0].count + 1;

    // ============================
    // ENUM SAFE MAPPING
    // ============================

    let safeVisitPurpose = 'Enjoy Experience';
    if (visit_purpose === 'Assignment/study') safeVisitPurpose = 'Assignment/Study';
    else if (visit_purpose === 'Education') safeVisitPurpose = 'Education';
    else if (visit_purpose === 'Tourism') safeVisitPurpose = 'Tourism';
    else if (visit_purpose === 'Religious') safeVisitPurpose = 'Religious';

    let safeExplanation = 'Balanced';
    if (explanation_type === 'Short') safeExplanation = 'Short Highlights';
    else if (explanation_type === 'Long') safeExplanation = 'Long Detailed';

    let safeTimeline = 'Past to Present';
    if (timeline_direction === 'Present to Past') {
      safeTimeline = 'Present to Past';
    }

    let safePreferredTime = 'Day';
    if (preferred_time === 'Night') safePreferredTime = 'Night';
    else if (preferred_time === 'Both') safePreferredTime = 'Both';

    // ============================
    // INSERT VISITOR
    // ============================
    await db.query(
      `INSERT INTO visitor (
        name,
        age_group,
        visit_purpose,
        interest_architecture,
        interest_history,
        interest_spirituality,
        interest_art,
        visited_before,
        language_level,
        explanation_type,
        time_budget,
        timeline_direction,
        preferred_time,
        buddhist_history_knowledge,
        queue_number,
        status
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        temp.name,
        age_group || '19-25',
        safeVisitPurpose,
        interest_architecture || 'Low',
        interest_history || 'Low',
        interest_spirituality || 'Low',
        interest_art || 'Low',
        visited_before ? 1 : 0,
        language_level || 'Simple',
        safeExplanation,
        temp.duration,
        safeTimeline,
        safePreferredTime,
        buddhist_history_knowledge ? 1 : 0,
        queueNumber,
        'waiting'
      ]
    );

    // 🧹 Clear temp
    delete tempVisitors[token];

    res.json({ message: 'Visitor data saved successfully' });

  } catch (err) {
    console.error('DB ERROR:', err);
    res.status(500).json({ message: 'Failed to save visitor' });
  }
});

// ============================
// VISITOR LIST (QUEUE VIEW)
// ============================
router.get('/list', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT visitor_id, name, status, queue_number
       FROM visitor
       ORDER BY
         CASE status
           WHEN 'waiting' THEN 1
           WHEN 'active' THEN 2
           WHEN 'completed' THEN 3
           WHEN 'cancelled' THEN 4
           ELSE 5
         END,
         queue_number ASC`
    );

    res.json(rows);

  } catch (err) {
    console.error('VISITOR LIST ERROR:', err);
    res.status(500).json({ message: 'Failed to fetch visitor list' });
  }
});

// ============================
// CANCEL VISITOR
// ============================
router.post('/cancel', async (req, res) => {
  const { visitor_id } = req.body;

  if (!visitor_id) {
    return res.status(400).json({ message: 'visitor_id is required' });
  }

  try {
    await db.query(
      "UPDATE visitor SET status='cancelled' WHERE visitor_id=?",
      [visitor_id]
    );

    res.json({ message: 'Visitor cancelled successfully' });

  } catch (err) {
    console.error('CANCEL ERROR:', err);
    res.status(500).json({ message: 'Failed to cancel visitor' });
  }
});

module.exports = router;
