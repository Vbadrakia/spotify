class AppConfig {
  // Use environment-based configuration
  // For production, set this to your production API URL
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:3000');
  static const String apiUrl = '$baseUrl/api';
  
  static String resolveUrl(String? path) {
    if (path == null) return '';
    if (path.startsWith('http')) return path;
    if (path.startsWith('/')) return '$baseUrl$path';
    return '$baseUrl/$path';
  }
}
