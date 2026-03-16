const express = require('express');
const Playlist = require('../models/Playlist');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Get all playlists for user
router.get('/', auth, async (req, res) => {
  try {
    const playlists = await Playlist.find({ createdBy: req.userId })
      .populate('tracks')
      .sort({ createdAt: -1 });
    
    res.json({ playlists });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching playlists', error: error.message });
  }
});

// Get single playlist
router.get('/:id', auth, async (req, res) => {
  try {
    const playlist = await Playlist.findById(req.params.id)
      .populate('tracks')
      .populate('createdBy', 'name');
    
    if (!playlist) {
      return res.status(404).json({ message: 'Playlist not found' });
    }
    
    res.json({ playlist });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching playlist', error: error.message });
  }
});

// Create playlist
router.post('/', auth, async (req, res) => {
  try {
    const { name, description } = req.body;
    
    const playlist = new Playlist({
      name,
      description,
      createdBy: req.userId,
    });
    
    await playlist.save();
    
    res.status(201).json({
      message: 'Playlist created',
      playlist,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error creating playlist', error: error.message });
  }
});

// Update playlist
router.put('/:id', auth, async (req, res) => {
  try {
    const { name, description, artwork } = req.body;
    
    const playlist = await Playlist.findOne({
      _id: req.params.id,
      createdBy: req.userId,
    });
    
    if (!playlist) {
      return res.status(404).json({ message: 'Playlist not found' });
    }
    
    if (name) playlist.name = name;
    if (description !== undefined) playlist.description = description;
    if (artwork) playlist.artwork = artwork;
    
    await playlist.save();
    
    res.json({
      message: 'Playlist updated',
      playlist,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error updating playlist', error: error.message });
  }
});

// Delete playlist
router.delete('/:id', auth, async (req, res) => {
  try {
    const playlist = await Playlist.findOneAndDelete({
      _id: req.params.id,
      createdBy: req.userId,
    });
    
    if (!playlist) {
      return res.status(404).json({ message: 'Playlist not found' });
    }
    
    res.json({ message: 'Playlist deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting playlist', error: error.message });
  }
});

// Add track to playlist
router.post('/:id/tracks', auth, async (req, res) => {
  try {
    const { trackId } = req.body;
    
    const playlist = await Playlist.findOne({
      _id: req.params.id,
      createdBy: req.userId,
    });
    
    if (!playlist) {
      return res.status(404).json({ message: 'Playlist not found' });
    }
    
    // Check if track already exists
    if (playlist.tracks.includes(trackId)) {
      return res.status(400).json({ message: 'Track already in playlist' });
    }
    
    playlist.tracks.push(trackId);
    await playlist.save();
    
    const updatedPlaylist = await Playlist.findById(playlist._id)
      .populate('tracks');
    
    res.json({
      message: 'Track added to playlist',
      playlist: updatedPlaylist,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error adding track', error: error.message });
  }
});

// Remove track from playlist
router.delete('/:id/tracks/:trackId', auth, async (req, res) => {
  try {
    const playlist = await Playlist.findOne({
      _id: req.params.id,
      createdBy: req.userId,
    });
    
    if (!playlist) {
      return res.status(404).json({ message: 'Playlist not found' });
    }
    
    playlist.tracks = playlist.tracks.filter(
      t => t.toString() !== req.params.trackId
    );
    await playlist.save();
    
    const updatedPlaylist = await Playlist.findById(playlist._id)
      .populate('tracks');
    
    res.json({
      message: 'Track removed from playlist',
      playlist: updatedPlaylist,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error removing track', error: error.message });
  }
});

module.exports = router;
