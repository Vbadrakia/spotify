const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');
const { body, validationResult } = require('express-validator');
const Track = require('../models/Track');
const User = require('../models/User');
const { auth, optionalAuth } = require('../middleware/auth');

const router = express.Router();

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, '../uploads');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueName = `${uuidv4()}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 50 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/ogg', 'audio/flac'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only audio files are allowed.'));
    }
  },
});

// Validation middleware
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ message: 'Validation error', errors: errors.array() });
  }
  next();
};

// Track upload validation rules
const trackUploadValidation = [
  body('title').trim().notEmpty().withMessage('Title is required')
    .isLength({ max: 200 }).withMessage('Title must be less than 200 characters'),
  body('artist').trim().notEmpty().withMessage('Artist is required')
    .isLength({ max: 200 }).withMessage('Artist must be less than 200 characters'),
  body('album').optional().trim().isLength({ max: 200 }).withMessage('Album must be less than 200 characters'),
  body('lyrics').optional().trim().isLength({ max: 10000 }).withMessage('Lyrics must be less than 10000 characters'),
];

// Get all tracks with pagination
router.get('/', optionalAuth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const tracks = await Track.find()
      .populate('uploadedBy', 'name avatar')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Track.countDocuments();

    res.json({
      tracks,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching tracks', error: error.message });
  }
});

// Get recently played
router.get('/recent', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    const recentTrackIds = user.recentlyPlayed || [];
    const tracks = await Track.find({ _id: { $in: recentTrackIds } })
      .populate('uploadedBy', 'name avatar');
    const trackMap = new Map(tracks.map(t => [t._id.toString(), t]));
    const orderedTracks = recentTrackIds.map(id => trackMap.get(id.toString())).filter(t => t !== undefined);
    res.json({ tracks: orderedTracks });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching recent tracks', error: error.message });
  }
});

// Get popular tracks
router.get('/popular', optionalAuth, async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 20;
    const tracks = await Track.find()
      .populate('uploadedBy', 'name avatar')
      .sort({ playCount: -1 })
      .limit(limit);
    res.json({ tracks });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching popular tracks', error: error.message });
  }
});

// Search tracks
router.get('/search', optionalAuth, async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) return res.json({ tracks: [] });

    const tracks = await Track.find({
      $or: [
        { title: { $regex: q, $options: 'i' } },
        { artist: { $regex: q, $options: 'i' } },
        { album: { $regex: q, $options: 'i' } },
      ],
    })
      .populate('uploadedBy', 'name avatar')
      .limit(50);
    res.json({ tracks });
  } catch (error) {
    res.status(500).json({ message: 'Error searching tracks', error: error.message });
  }
});

// Get lyrics for a track (public)
router.get('/:id/lyrics', async (req, res) => {
  try {
    const track = await Track.findById(req.params.id).select('lyrics title artist');
    if (!track) {
      return res.status(404).json({ message: 'Track not found' });
    }
    res.json({
      trackId: track._id,
      title: track.title,
      artist: track.artist,
      lyrics: track.lyrics
    });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching lyrics', error: error.message });
  }
});

// Fetch lyrics from external API (placeholder)
router.get('/:id/fetch-lyrics', async (req, res) => {
  try {
    const track = await Track.findById(req.params.id);
    if (!track) {
      return res.status(404).json({ message: 'Track not found' });
    }

    // In production, you would call a lyrics API like Genius, Musixmatch, etc.
    // For now, return a placeholder
    res.json({
      message: 'Lyrics fetch not implemented. Please add lyrics manually.',
      trackId: track._id
    });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching lyrics', error: error.message });
  }
});

// Get single track
router.get('/:id', optionalAuth, async (req, res) => {
  try {
    const track = await Track.findById(req.params.id)
      .populate('uploadedBy', 'name avatar');

    if (!track) {
      return res.status(404).json({ message: 'Track not found' });
    }

    track.playCount += 1;
    await track.save();

    if (req.userId) {
      const user = await User.findById(req.userId);
      let recent = user.recentlyPlayed || [];
      recent = recent.filter(id => id.toString() !== track._id.toString());
      recent.unshift(track._id);
      recent = recent.slice(0, 50);
      user.recentlyPlayed = recent;
      await user.save();
    }

    res.json({ track });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching track', error: error.message });
  }
});

// Upload track with lyrics
router.post('/', auth, trackUploadValidation, validate, upload.fields([
  { name: 'audio', maxCount: 1 },
  { name: 'artwork', maxCount: 1 }
]), async (req, res) => {
  try {
    const { title, artist, album, lyrics } = req.body;

    if (!req.files || !req.files['audio']) {
      return res.status(400).json({ message: 'Audio file is required' });
    }

    const audioFile = req.files['audio'][0];
    const artworkFile = req.files['artwork'] ? req.files['artwork'][0] : null;

    const track = new Track({
      title,
      artist,
      album,
      lyrics: lyrics || null,
      audioUrl: `/uploads/${audioFile.filename}`,
      artwork: artworkFile ? `/uploads/${artworkFile.filename}` : null,
      uploadedBy: req.userId,
    });

    await track.save();

    res.status(201).json({
      message: 'Track uploaded successfully',
      track,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error uploading track', error: error.message });
  }
});

// Update track including lyrics
router.put('/:id', auth, async (req, res) => {
  try {
    const { title, artist, album, artwork, lyrics } = req.body;

    const track = await Track.findOne({
      _id: req.params.id,
      uploadedBy: req.userId,
    });

    if (!track) {
      return res.status(404).json({ message: 'Track not found or unauthorized' });
    }

    if (title) track.title = title;
    if (artist) track.artist = artist;
    if (album !== undefined) track.album = album;
    if (artwork) track.artwork = artwork;
    if (lyrics !== undefined) track.lyrics = lyrics;

    await track.save();

    res.json({ message: 'Track updated', track });
  } catch (error) {
    res.status(500).json({ message: 'Error updating track', error: error.message });
  }
});

// Delete track
router.delete('/:id', auth, async (req, res) => {
  try {
    const track = await Track.findOne({
      _id: req.params.id,
      uploadedBy: req.userId,
    });

    if (!track) {
      return res.status(404).json({ message: 'Track not found or unauthorized' });
    }

    const audioPath = path.join(__dirname, '../../', track.audioUrl);
    if (fs.existsSync(audioPath)) {
      fs.unlinkSync(audioPath);
    }

    await track.deleteOne();

    res.json({ message: 'Track deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting track', error: error.message });
  }
});

module.exports = router;
