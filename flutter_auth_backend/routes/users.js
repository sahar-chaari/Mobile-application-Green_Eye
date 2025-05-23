const express = require('express');
const router = express.Router();
const User = require('../models/User');
const multer = require('multer');
const path = require('path');



// 🔧 Configure image upload
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'public/images'),
  filename: (req, file, cb) => {
    const uniqueName = 'profile-' + Date.now() + path.extname(file.originalname);
    cb(null, uniqueName);
  }
});
const upload = multer({ storage });

// ✅ GET user by ID (excluding password)
router.get('/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: 'Error fetching user' });
  }
});

// ✅ PUT update user profile
router.put('/:id', async (req, res) => {
  try {
    const updateFields = {};

    if (req.body.name !== undefined) updateFields.name = req.body.name;
    if (req.body.lastname !== undefined) updateFields.lastname = req.body.lastname;
    if (req.body.birthday !== undefined) updateFields.birthday = req.body.birthday;
    if (req.body.robotType !== undefined) updateFields.robotType = req.body.robotType;
    if (req.body.location !== undefined) updateFields.location = req.body.location;
    if (req.body.phone !== undefined) updateFields.phone = req.body.phone;
    if (req.body.image !== undefined) updateFields.image = req.body.image;

    const updated = await User.findByIdAndUpdate(
      req.params.id,
      { $set: updateFields },
      { new: true }
    ).select('-password');

    res.json(updated);
  } catch (err) {
    console.error('Error updating profile:', err);
    res.status(500).json({ error: 'Error updating profile' });
  }
});

// ✅ POST profile image upload
// Upload endpoint
router.post('/upload-image/:id', upload.single('image'), async (req, res) => {
  try {
    const filename = req.file.filename;
    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      { image: filename },
      { new: true }
    ).select('-password');
    res.json(updatedUser);
  } catch (err) {
    res.status(500).json({ error: 'Error uploading image' });
  }
});

// ✅ GET user ID by email (used after login)
router.get('/by-email/:email', async (req, res) => {
  try {
    const user = await User.findOne({ email: req.params.email }).select('_id');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json({ userId: user._id });
  } catch (err) {
    res.status(500).json({ error: 'Error finding user by email' });
  }
});

module.exports = router;