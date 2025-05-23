const express = require('express');
const router = express.Router();
const Disease = require('../models/Disease');
const mongoose = require('mongoose');

// GET all diseases
router.get('/', async (req, res) => {
  try {
    const diseases = await Disease.find();
    res.json(diseases);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch diseases' });
  }
});

// ADD fixed diseases (optional: run once)
router.post('/seed', async (req, res) => {
  try {
    const data = req.body; // [{ title, description, recommendation, image }]
    await Disease.insertMany(data);
    res.status(201).json({ message: 'Diseases seeded' });
  } catch (err) {
    res.status(500).json({ error: 'Seeding failed' });
  }
});

// DELETE by ID
router.delete('/:id', async (req, res) => {
  try {
    const result = await Disease.deleteOne({ _id: new mongoose.Types.ObjectId(req.params.id) });
    if (result.deletedCount === 0) {
      return res.status(404).json({ error: 'Disease not found' });
    }
    res.json({ status: 'deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Server error during deletion' });
  }
});

module.exports = router;