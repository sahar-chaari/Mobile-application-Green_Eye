const express = require('express');
const mongoose = require('mongoose');
const { MongoClient, ObjectId } = require('mongodb');
const cors = require('cors');
require('dotenv').config();

// Route files
const authRoutes = require('./routes/auth');         // Optional
const dataRoutes = require('./routes/data');
const diseaseRoutes = require('./routes/diseases');
const collectionsRoutes = require('./routes/collections');
const detectionRoutes = require('./routes/detections');
const usersRoutes = require('./routes/users');
const app = express();
const PORT = 5000;

// ✅ Use your correct MongoDB URI
const MONGO_URI = 'mongodb+srv://ahmed:ahmed123%2E%2E@cluster0.87ihpdb.mongodb.net/test?retryWrites=true&w=majority&appName=Cluster0';

// ✅ Serve images from public/images and uploads
app.use('/images', express.static('public/images'));
app.use('/uploads', express.static('uploads'));

// ✅ Middleware
app.use(cors());
app.use(express.json());

// ✅ Connect to MongoDB via Mongoose (for models)
mongoose.connect(MONGO_URI)
  .then(() => console.log('✅ Connected to MongoDB via Mongoose'))
  .catch(err => console.error('❌ Mongoose connection error:', err));

// ✅ API routes
app.use('/api', authRoutes);             // Optional
app.use('/api', dataRoutes);
app.use('/api', diseaseRoutes);
app.use('/api/collections', collectionsRoutes);
app.use('/api', detectionRoutes);        // Includes GET/POST detections with userId
app.use('/api/users', usersRoutes);      // For profile details and user info

// ✅ Optional fallback 404
app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

// ✅ Start server immediately (not inside MongoClient)
app.listen(PORT, () => {
  console.log(`✅ Server started on http://localhost:${PORT}`);
});