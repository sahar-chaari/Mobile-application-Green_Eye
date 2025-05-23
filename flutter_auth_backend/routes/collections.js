const express = require('express');
const router = express.Router();
const Collection = require('../models/Collection');

router.get('/', async (req, res) => {
  try {
    const collections = await Collection.find();
    res.json(collections);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch collections' });
  }
});

router.post('/', async (req, res) => {
  try {
    const { name, description } = req.body;
    const newCollection = new Collection({ name, description });
    await newCollection.save();
    res.status(201).json(newCollection);
  } catch (err) {
    res.status(500).json({ error: 'Failed to create collection' });
  }
});

module.exports = router;
