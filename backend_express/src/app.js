require('dotenv').config();

function validateEnv() {
  const required = [
    'PORT',
    'DB_HOST',
    'DB_PORT',
    'DB_NAME',
    'DB_USER',
    'FIREBASE_PROJECT_ID',
    'FIREBASE_CLIENT_EMAIL',
    'FIREBASE_PRIVATE_KEY',
  ];

  const missing = required.filter((key) => {
    const value = process.env[key];
    return value === undefined || value === null || String(value).trim() === '';
  });

  if (missing.length > 0) {
    console.error('==========================================');
    console.error(' MISSING ENVIRONMENT VARIABLES');
    console.error('==========================================');
    missing.forEach((key) => {
      console.error(` ❌  ${key} is not set`);
    });
    console.error('==========================================');
    console.error(' Fix: Fill in the missing variables in your .env file.');
    console.error(' See .env.example for the list of required variables.');
    console.error(' Get Firebase credentials from:');
    console.error(
      ' Firebase Console → Project Settings → Service Accounts → Generate new private key',
    );
    console.error('==========================================');
    process.exit(1);
  }

  console.log('✅  All required environment variables are set.');
}

validateEnv();

const express = require('express');
const cors = require('cors');
const errorMiddleware = require('./middleware/errorMiddleware');
const normalizeBodyMiddleware = require('./middleware/normalizeBodyMiddleware');

const app = express();

app.use(cors());
app.use(express.json());
app.use(normalizeBodyMiddleware);

app.get('/', (req, res) => {
  res.json({ message: 'Smart Travel Planner API is running' });
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', service: 'Smart Travel Planner Backend' });
});

// In house APIs
app.use('/api/profile', require('./routes/profileRoutes'));
app.use('/api/trips', require('./routes/tripRoutes'));
app.use('/api/itineraries', require('./routes/itineraryRoutes'));
app.use('/api/itinerary-items', require('./routes/itineraryItemRoutes'));
app.use('/api/expenses', require('./routes/expenseRoutes'));

// Third-party APIs
app.use('/api/weather', require('./routes/weatherRoutes'));
app.use('/api/geocode', require('./routes/geocodeRoutes'));

app.use('/api/attractions', require('./routes/attractionRoutes'));
app.use('/api/hotels', require('./routes/hotelRoutes'));
app.use('/api/restaurants', require('./routes/restaurantRoutes'));

app.use('/api/country-info', require('./routes/countryRoutes'));
app.use('/api/locations', require('./routes/locationRoutes'));

app.use(errorMiddleware);

const PORT = process.env.PORT;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
