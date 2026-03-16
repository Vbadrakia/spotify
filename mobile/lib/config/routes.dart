import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main/main_screen.dart';
import '../screens/player/full_player_screen.dart';
import '../screens/player/lyrics_screen.dart';
import '../screens/playlist/create_playlist_screen.dart';
import '../screens/playlist/playlist_detail_screen.dart';
import '../screens/track/upload_track_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/library/library_screen.dart';
import '../models/track_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String home = '/home';
  static const String search = '/search';
  static const String library = '/library';
  static const String fullPlayer = '/player';
  static const String lyrics = '/lyrics';
  static const String createPlaylist = '/playlist/create';
  static const String playlistDetail = '/playlist/:id';
  static const String uploadTrack = '/upload';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case fullPlayer:
        return MaterialPageRoute(builder: (_) => const FullPlayerScreen());
      case lyrics:
        final track = settings.arguments as Track;
        return MaterialPageRoute(builder: (_) => LyricsScreen(track: track));
      case createPlaylist:
        return MaterialPageRoute(builder: (_) => const CreatePlaylistScreen());
      case playlistDetail:
        final id = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => PlaylistDetailScreen(playlistId: id));
      case uploadTrack:
        return MaterialPageRoute(builder: (_) => const UploadTrackScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text('No route defined for ${settings.name}'))),
        );
    }
  }
}
