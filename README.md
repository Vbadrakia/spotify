# SoundWave - Music Streaming App 🎵

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?style=flat&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Node.js-18+-green?style=flat&logo=node.js" alt="Node.js">
  <img src="https://img.shields.io/badge/MongoDB-Ready-green?style=flat&logo=mongodb" alt="MongoDB">
</p>

An original music streaming application built with Flutter and Node.js. Upload your own music, create playlists, and stream anywhere!

---

## ⬇️ Download APK

**[Download SoundWave APK (Debug)](https://github.com/Vbadrakia/spotify/releases)**

> **Note:** Build the APK yourself (see below) or check Releases for pre-built versions.

---

## ✨ Features

| Category | Features |
|----------|----------|
| **Authentication** | Email/password registration, JWT login, Profile management |
| **Music Player** | Play/Pause/Stop, Next/Previous, Seek, Volume, Background playback, Shuffle, Repeat mode, Queue management |
| **Library** | All Tracks, Playlists, Favorites, Recently Played, Most Played |
| **Search** | Search by title, artist, album |
| **Upload** | Upload tracks with title, artist, album, artwork, lyrics |
| **Lyrics** | View and add lyrics to tracks |
| **Playlists** | Create, edit, delete playlists, add/remove tracks |

---

## 🏗️ Tech Stack

- **Mobile:** Flutter 3.x + BLoC + just_audio
- **Backend:** Node.js + Express + MongoDB + Mongoose
- **Auth:** JWT + bcrypt
- **Storage:** Local file system (Multer)

---

## 🚀 Quick Start

### 1. Backend (Required)

```bash
# Clone the repo
git clone https://github.com/Vbadrakia/spotify.git
cd spotify/backend

# Install dependencies
npm install

# Create .env file
cp .env.example .env
```

Edit `.env`:
```
PORT=3000
MONGODB_URI=mongodb://localhost:27017/soundwave
JWT_SECRET=your-secret-key-here
```

**Start MongoDB** (or use MongoDB Atlas), then:
```bash
npm start
# Server runs at http://localhost:3000
```

---

### 2. Mobile App

```bash
cd ../mobile

# Get Flutter dependencies
flutter pub get
```

**Important:** Update API URL in `lib/config/di.dart`:
```dart
// Change this:
baseUrl: 'http://localhost:3000/api'

// To your server IP:
baseUrl: 'http://YOUR_SERVER_IP:3000/api'
```

#### Build APK:
```bash
flutter build apk --debug
```

The APK will be at: `build/app/outputs/flutter-apk/app-debug.apk`

#### Or Run on Device:
```bash
flutter run
```

---

## 📱 Mobile Setup (Android)

1. Enable **Developer Mode** on your phone
2. Connect via USB or WiFi
3. Run: `flutter run`

For APK install:
```bash
# Build release APK
flutter build apk --release

# Install on connected device
flutter install
```

---

## 🔧 API Configuration

For local development, use `localhost`. For production:

1. Deploy backend to **Render**, **Railway**, or **VPS**
2. Update MongoDB to **MongoDB Atlas**
3. Change API URL in mobile app

---

## 📂 Project Structure

```
spotify/
├── backend/           # Node.js API
│   ├── src/
│   │   ├── index.js
│   │   ├── models/   # User, Track, Playlist
│   │   ├── routes/   # Auth, Tracks, Playlists, Favorites
│   │   └── middleware/
│   └── package.json
│
├── mobile/           # Flutter App
│   ├── lib/
│   │   ├── main.dart
│   │   ├── config/   # Theme, Routes, DI
│   │   ├── models/   # Data models
│   │   ├── bloc/     # State management
│   │   ├── services/ # API & Audio services
│   │   ├── screens/  # All UI screens
│   │   └── widgets/  # Reusable widgets
│   └── pubspec.yaml
│
└── README.md
```

---

## 🔐 Environment Variables

### Backend (.env)
```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/soundwave
JWT_SECRET=your-super-secret-key
```

---

## 📖 API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/login` | Login |
| GET | `/api/auth/profile` | Get profile |
| PUT | `/api/auth/profile` | Update profile |

### Tracks
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/tracks` | List all tracks |
| GET | `/api/tracks/search?q=` | Search tracks |
| GET | `/api/tracks/:id` | Get track |
| POST | `/api/tracks` | Upload track |
| DELETE | `/api/tracks/:id` | Delete track |

### Playlists
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/playlists` | User playlists |
| POST | `/api/playlists` | Create playlist |
| PUT | `/api/playlists/:id` | Update playlist |
| DELETE | `/api/playlists/:id` | Delete playlist |

### Favorites
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/favorites` | Get favorites |
| POST | `/api/favorites/:trackId` | Add favorite |
| DELETE | `/api/favorites/:trackId` | Remove favorite |

---

## 🌐 Deploy to Production

### Backend (Render/Railway):
1. Connect GitHub repo
2. Set environment variables
3. Build command: `npm start`

### Mobile:
1. Build release APK
2. Upload to GitHub Releases
3. Or publish to Google Play Store

---

## ⚖️ License

This is an **original app** - not a Spotify clone. Built for learning and personal use.

---

<p align="center">Built with ❤️ using Flutter & Node.js</p>
