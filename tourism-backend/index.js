const express = require('express');
const cors = require('cors');
require('dotenv').config();

// ROUTES
const adminRoutes = require('./routes/admin');
const visitorRoutes = require('./routes/visitor');

const app = express();

app.use(cors());
app.use(express.json());

// 🔹 SERVE WEB PAGES (QR WEB FORM)
app.use(express.static('public'));

// REGISTER ROUTES
app.use('/api/admin', adminRoutes);
app.use('/api/visitor', visitorRoutes);

// ROOT TEST
app.get('/', (req, res) => {
  res.send('HeritXr Admin Backend Running');
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
