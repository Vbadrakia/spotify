# SoundWave - Music Streaming App

An original music streaming application built with Flutter and Node.js. This is a complete full-stack music streaming platform - NOT a Spotify clone. It's designed to be your own music streaming service.

## Project Structure

```
spotify-clone/
├── mobile/     # Flutter app
└── backend/    # Node.js API
```

## Tech Stack

### Mobile (Flutter)
- **Framework:** Flutter 3.x
- **State Management:** BLoC pattern
- **Audio:** just_audio, audio_service
- **HTTP:** dio
- **Local Storage:** hive, shared_preferences

### Backend (Node.js)
- **Runtime:** Node.js + Express
- **Database:** MongoDB with Mongoose
- **Auth:** JWT + bcrypt
- **File Storage:** Multer

## Features

### Authentication
- ✅ User registration (email/password)
- ✅ User login with JWT
- ✅ Profile management

### Music Management
- ✅ Upload tracks
- ✅ Browse all tracks
- ✅ Search tracks
- ✅ Delete own tracks

### Player
- ✅ Play/pause/stop
- ✅ Next/previous track
- ✅ Seek functionality
- ✅ Background playback
- ✅ Queue management

### Playlists
- ✅ Create playlist
- ✅ Add/remove tracks
- ✅ Delete playlist

### Favorites
- ✅ Add/remove favorites

## Getting Started

### Prerequisites

**Mobile:**
- Flutter SDK 3.x
- Android Studio / VS Code
- Android SDK

**Backend:**
- Node.js 18+
- MongoDB (local or Atlas)

### Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Create .env file
cp .env.example .env
# Edit .env with your MongoDB URI and JWT secret

# Start the server
npm run dev
```

The API will be available at `http://localhost:3000`

### Mobile Setup

```bash
cd mobile

# Get dependencies
flutter pub get

# Update API base URL in lib/config/di.dart

# Run the app
flutter run
```

## API Endpoints

### Auth
- POST `/api/auth/register` - Register new user
- POST `/api/auth/login` - Login
- GET `/api/auth/profile` - Get profile
- PUT `/api/auth/profile` - Update profile

### Tracks
- GET `/api/tracks` - List all tracks
- GET `/api/tracks/search?q=` - Search tracks
- GET `/api/tracks/:id` - Get single track
- POST `/api/tracks` - Upload track
- DELETE `/api/tracks/:id` - Delete track

### Playlists
- GET `/api/playlists` - User playlists
- GET `/api/playlists/:id` - Playlist details
- POST `/api/playlists` - Create playlist
- PUT `/api/playlists/:id` - Update playlist
- DELETE `/api/playlists/:id` - Delete playlist
- POST `/api/playlists/:id/tracks` - Add track
- DELETE `/api/playlists/:id/tracks/:trackId` - Remove track

### Favorites
- GET `/api/favorites` - Get favorites
- POST `/api/favorites/:trackId` - Add to favorites
- DELETE `/api/favorites/:trackId` - Remove from favorites

## Building APK

```bash
cd mobile
flutter build apk --debug
```

The APK will be at `build/app/outputs/flutter-apk/app-debug.apk`

## Original Design

This app is an **original design** inspired by music streaming functionality. It is NOT affiliated with or copying Spotify. The name "SoundWave" and all UI elements are original.

---

*Built with ❤️ using Flutter & Node.js*
