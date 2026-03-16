import 'dart:convert';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final AuthService _authService;
  final SharedPreferences _prefs;
  
  static const String _userKey = 'user_data';

  AuthRepository({
    required AuthService authService,
    required SharedPreferences prefs,
  })  : _authService = authService,
        _prefs = prefs;

  bool get isLoggedIn => _authService.hasToken;

  User? get cachedUser {
    final userData = _prefs.getString(_userKey);
    if (userData != null) {
      try {
        return User.fromJson(json.decode(userData));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _authService.register(
      email: email,
      password: password,
      name: name,
    );
    
    if (response['token'] != null) {
      await _authService.setToken(response['token']);
    }
    
    final user = User.fromJson(response['user'] ?? response);
    await _saveUser(user);
    return user;
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _authService.login(
      email: email,
      password: password,
    );
    
    if (response['token'] != null) {
      await _authService.setToken(response['token']);
    }
    
    final user = User.fromJson(response['user'] ?? response);
    await _saveUser(user);
    return user;
  }

  Future<User> getProfile() async {
    final user = await _authService.getProfile();
    await _saveUser(user);
    return user;
  }

  Future<User> updateProfile({
    String? name,
    String? avatar,
  }) async {
    final user = await _authService.updateProfile(
      name: name,
      avatar: avatar,
    );
    await _saveUser(user);
    return user;
  }

  Future<void> logout() async {
    await _authService.logout();
    await _prefs.remove(_userKey);
  }

  Future<void> _saveUser(User user) async {
    await _prefs.setString(_userKey, json.encode(user.toJson()));
  }
}
