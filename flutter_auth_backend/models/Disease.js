// models/Disease.js
const mongoose = require('mongoose');

const diseaseSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String, required: true },
  recommendation: { type: String, required: true },
  image: { type: String, required: true } // Path to the image stored locally or on a CDN
});

module.exports = mongoose.model('Disease', diseaseSchema);