// server.js or a separate db.js
const mongoose = require('mongoose');

// Replace with your MongoDB URI
const MONGO_URI = 'mongodb://127.0.0.1:27017/yourDatabaseName';

mongoose.connect(MONGO_URI)
  .then(() => {
    console.log('✅ MongoDB Connected');
  })
  .catch((err) => {
    console.error('❌ MongoDB connection error:', err);
  });