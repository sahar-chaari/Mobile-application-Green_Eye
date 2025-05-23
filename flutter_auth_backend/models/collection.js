const mongoose = require('mongoose');

const collectionSchema = new mongoose.Schema({
  name: String,
  description: String,
});

module.exports = mongoose.model('Collection', collectionSchema);
