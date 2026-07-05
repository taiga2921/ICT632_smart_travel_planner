const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    message: 'Smart Travel Planner API is running',
  });
});

app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    service: 'Smart Travel Planner Backend',
  });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
