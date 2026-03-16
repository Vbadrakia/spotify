import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/track_service.dart';
import '../services/playlist_service.dart';
import '../services/audio_player_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/track_repository.dart';
import '../repositories/playlist_repository.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/player/player_bloc.dart';
import '../bloc/track/track_bloc.dart';
import '../bloc/playlist/playlist_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000/api',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));
  getIt.registerSingleton<Dio>(dio);
  
  // Services
  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>(), getIt<SharedPreferences>()));
  getIt.registerLazySingleton<AuthService>(() => AuthService(getIt<ApiService>()));
  getIt.registerLazySingleton<TrackService>(() => TrackService(getIt<ApiService>()));
  getIt.registerLazySingleton<PlaylistService>(() => PlaylistService(getIt<ApiService>()));
  getIt.registerLazySingleton<AudioPlayerService>(() => AudioPlayerService());
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(authService: getIt<AuthService>(), prefs: getIt<SharedPreferences>()));
  getIt.registerLazySingleton<TrackRepository>(() => TrackRepository(getIt<TrackService>()));
  getIt.registerLazySingleton<PlaylistRepository>(() => PlaylistRepository(getIt<PlaylistService>()));
  
  // BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory<PlayerBloc>(() => PlayerBloc(getIt<AudioPlayerService>()));
  getIt.registerFactory<TrackBloc>(() => TrackBloc(getIt<TrackRepository>()));
  getIt.registerFactory<PlaylistBloc>(() => PlaylistBloc(getIt<PlaylistRepository>()));
}
