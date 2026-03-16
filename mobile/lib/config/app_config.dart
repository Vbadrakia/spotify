class AppConfig {
  static const String baseUrl = 'http://localhost:3000';
  static const String apiUrl = '$baseUrl/api';
  
  static String resolveUrl(String? path) {
    if (path == null) return '';
    if (path.startsWith('http')) return path;
    if (path.startsWith('/')) return '$baseUrl$path';
    return '$baseUrl/$path';
  }
}
