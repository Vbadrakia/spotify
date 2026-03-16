const express = require('express');
const User = require('../models/User');
const Track = require('../models/Track');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Get favorites
router.get('/', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId).populate({
      path: 'favorites',
      populate: { path: 'uploadedBy', select: 'name' },
    });
    
    res.json({ tracks: user.favorites || [] });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching favorites', error: error.message });
  }
});

// Add to favorites
router.post('/:trackId', auth, async (req, res) => {
  try {
    const track = await Track.findById(req.params.trackId);
    
    if (!track) {
      return res.status(404).json({ message: 'Track not found' });
    }
    
    const user = await User.findById(req.userId);
    
    // Check if already in favorites
    if (user.favorites.includes(req.params.trackId)) {
      return res.status(400).json({ message: 'Track already in favorites' });
    }
    
    user.favorites.push(req.params.trackId);
    await user.save();
    
    const updatedUser = await User.findById(req.userId).populate({
      path: 'favorites',
      populate: { path: 'uploadedBy', select: 'name' },
    });
    
    res.json({
      message: 'Added to favorites',
      tracks: updatedUser.favorites,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error adding to favorites', error: error.message });
  }
});

// Remove from favorites
router.delete('/:trackId', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    
    user.favorites = user.favorites.filter(
      f => f.toString() !== req.params.trackId
    );
    await user.save();
    
    const updatedUser = await User.findById(req.userId).populate({
      path: 'favorites',
      populate: { path: 'uploadedBy', select: 'name' },
    });
    
    res.json({
      message: 'Removed from favorites',
      tracks: updatedUser.favorites,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error removing from favorites', error: error.message });
  }
});

module.exports = router;
