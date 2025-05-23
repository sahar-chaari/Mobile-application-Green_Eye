const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true
  },
  password: {
    type: String,
    required: true
  },
  image: {
    type: String, // Store filename or full URL
    default: ''
  },
  name: {
    type: String,
    default: ''
  },
  lastname: {
    type: String,
    default: ''
  },
  birthday: {
    type: String, // Or Date if you want to store as Date
    default: ''
  },
  robotType: {
    type: String,
    default: ''
  },
  location: {
    type: String,
    default: ''
  },
  phone: {
    type: String,
    default: ''
  }
});

module.exports = mongoose.models.User || mongoose.model('User', userSchema);