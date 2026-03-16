import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio;
  final SharedPreferences _prefs;
  final Function()? _onUnauthorized;
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _refreshTokenKey = 'refresh_token';

  ApiService(this._dio, this._prefs, {Function()? onUnauthorized}) : _onUnauthorized = onUnauthorized {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _prefs.getString(_tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try to refresh
          final refreshToken = _prefs.getString(_refreshTokenKey);
          if (refreshToken != null) {
            try {
              // Call refresh endpoint
              final response = await _dio.post(
                '/auth/refresh',
                data: {'refreshToken': refreshToken},
                options: Options(headers: {'Authorization': ''}), // Don't send old token
              );
              
              if (response.statusCode == 200 && response.data['accessToken'] != null) {
                // Save new token
                await _prefs.setString(_tokenKey, response.data['accessToken']);
                
                // Retry original request
                error.requestOptions.headers['Authorization'] = 'Bearer ${response.data['accessToken']}';
                final retryResponse = await _dio.fetch(error.requestOptions);
                return handler.resolve(retryResponse);
              }
            } catch (e) {
              // Refresh failed, clear auth data
              await _prefs.remove(_tokenKey);
              await _prefs.remove(_refreshTokenKey);
              await _prefs.remove(_userKey);
              _onUnauthorized?.call();
            }
          } else {
            // No refresh token, clear auth data
            await _prefs.remove(_tokenKey);
            await _prefs.remove(_userKey);
            _onUnauthorized?.call();
          }
        }
        return handler.next(error);
      },
    ));
  }

  // Token management
  Future<void> setToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> setRefreshToken(String? token) async {
    if (token != null) {
      await _prefs.setString(_refreshTokenKey, token);
    } else {
      await _prefs.remove(_refreshTokenKey);
    }
  }

  String? getRefreshToken() {
    return _prefs.getString(_refreshTokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_userKey);
  }

  bool get hasToken => _prefs.containsKey(_tokenKey);

  // User data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(_userKey, json.encode(userData));
  }

  Map<String, dynamic>? getUserData() {
    final data = _prefs.getString(_userKey);
    if (data != null) {
      try {
        return json.decode(data) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // HTTP Methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> uploadFiles<T>(
    String path,
    Map<String, String> files, {
    Map<String, dynamic>? data,
    void Function(int, int)? onSendProgress,
  }) async {
    final Map<String, dynamic> formDataMap = {...?data};
    
    for (var entry in files.entries) {
      if (entry.value.isNotEmpty) {
        formDataMap[entry.key] = await MultipartFile.fromFile(entry.value);
      }
    }

    final formData = FormData.fromMap(formDataMap);
    
    return _dio.post<T>(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}
