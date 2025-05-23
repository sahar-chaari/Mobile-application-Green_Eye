const express = require('express');
const router = express.Router();
const Detection = require('../models/Detection');

// ✅ GET /detections?userId=xxx
router.get('/', async (req, res) => {
  try {
    const { userId } = req.query;

    const query = userId ? { userId } : {};
    const detections = await Detection.find(query);

    res.json(detections);
  } catch (err) {
    console.error('Error fetching detections:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// ✅ POST /detections
router.post('/', async (req, res) => {
  try {
    const { filename, prediction, userId } = req.body;

    if (!userId || !filename || !prediction) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const newDetection = new Detection({
      filename,
      prediction,
      userId,
    });

    await newDetection.save();
    res.status(201).json(newDetection);
  } catch (err) {
    console.error('Error saving detection:', err);
    res.status(500).json({ error: 'Error saving detection' });
  }
});

// ✅ DELETE /detections/:filename
router.delete('/:filename', async (req, res) => {
  try {
    const { filename } = req.params;
    const result = await Detection.deleteOne({ filename });

    if (result.deletedCount === 0) {
      return res.status(404).json({ error: 'Detection not found' });
    }

    res.json({ message: 'Detection deleted' });
  } catch (err) {
    console.error('Error deleting detection:', err);
    res.status(500).json({ error: 'Error deleting detection' });
  }
});

module.exports = router;