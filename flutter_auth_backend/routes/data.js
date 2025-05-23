// routes/data.js
const express = require('express');
const router = express.Router();
const Disease = require('../models/Disease');

// GET all diseases
router.get('/diseases', async (req, res) => {
  const diseases = await Disease.find();
  res.json(diseases);
});

// POST new disease
router.post('/diseases', async (req, res) => {
  const { title, description } = req.body;
  const newDisease = new Disease({ title, description });
  await newDisease.save();
  res.json(newDisease);
});

// Similarly for collections...
module.exports = router;
