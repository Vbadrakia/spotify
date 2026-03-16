import '../services/api_service.dart';
import '../../models/user_model.dart';

class AuthService {
  final ApiService _api;

  AuthService(this._api);

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _api.post('/auth/register', data: {
      'email': email,
      'password': password,
      'name': name,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<User> getProfile() async {
    final response = await _api.get('/auth/profile');
    return User.fromJson(response.data['user'] ?? response.data);
  }

  Future<User> updateProfile({
    String? name,
    String? avatar,
  }) async {
    final response = await _api.put('/auth/profile', data: {
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
    });
    return User.fromJson(response.data['user'] ?? response.data);
  }

  Future<void> logout() async {
    await _api.clearToken();
  }
}
