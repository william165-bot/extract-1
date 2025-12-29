class AppConfig {
  static const String appName = 'CN-NETSHARE';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration dataRefreshInterval = Duration(seconds: 10);
  static const Duration hostListRefreshInterval = Duration(seconds: 15);
  
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String roleKey = 'user_role';
}
