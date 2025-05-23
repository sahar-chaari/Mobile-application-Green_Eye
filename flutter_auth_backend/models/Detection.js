const mongoose = require('mongoose');

const detectionSchema = new mongoose.Schema({
  filename: { type: String, required: true },
  prediction: { type: String, required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
}, { timestamps: true });

module.exports = mongoose.models.Detection || mongoose.model('Detection', detectionSchema);