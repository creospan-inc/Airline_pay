import 'package:flutter/foundation.dart';

/// Environment types
enum Environment {
  development,
  staging,
  production,
}

/// Configuration class for the application
class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final bool enableOfflineMode;
  final bool enableSyncLogs;
  final int syncInterval; // in minutes
  
  /// Singleton pattern
  static late AppConfig _instance;
  
  /// Factory constructor
  factory AppConfig.getInstance() {
    return _instance;
  }
  
  /// Constructor
  AppConfig._internal({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableOfflineMode,
    required this.enableSyncLogs,
    required this.syncInterval,
  });
  
  /// Initialize the configuration based on the environment
  static void initialize({Environment env = Environment.development}) {
    switch (env) {
      case Environment.development:
        _instance = AppConfig._internal(
          environment: Environment.development,
          apiBaseUrl: 'http://127.0.0.1:3000/api',
          enableOfflineMode: true,
          enableSyncLogs: true,
          syncInterval: 5, // 5 minutes
        );
        break;
      case Environment.staging:
        _instance = AppConfig._internal(
          environment: Environment.staging,
          apiBaseUrl: 'https://staging-api.skycomfort.app/api/v1',
          enableOfflineMode: true,
          enableSyncLogs: true,
          syncInterval: 10, // 10 minutes
        );
        break;
      case Environment.production:
        _instance = AppConfig._internal(
          environment: Environment.production,
          apiBaseUrl: 'https://api.skycomfort.app/api/v1',
          enableOfflineMode: true,
          enableSyncLogs: false,
          syncInterval: 15, // 15 minutes
        );
        break;
    }
  }
  
  /// Check if the app is running in development mode
  bool get isDevelopment => environment == Environment.development;
  
  /// Check if the app is running in staging mode
  bool get isStaging => environment == Environment.staging;
  
  /// Check if the app is running in production mode
  bool get isProduction => environment == Environment.production;
  
  /// Get the full API URL with endpoint
  String getApiUrl(String endpoint) {
    return '$apiBaseUrl/$endpoint';
  }
} 