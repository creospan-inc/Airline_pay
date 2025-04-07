import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

/// TokenManager handles secure storage and retrieval of authentication tokens
class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  
  final FlutterSecureStorage _secureStorage;
  
  // Singleton pattern
  static final TokenManager _instance = TokenManager._internal();
  
  factory TokenManager() {
    return _instance;
  }
  
  TokenManager._internal() : _secureStorage = const FlutterSecureStorage();
  
  /// Saves authentication tokens to secure storage
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: _tokenExpiryKey, value: expiry.toIso8601String());
  }
  
  /// Retrieves the current access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }
  
  /// Retrieves the refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }
  
  /// Checks if the current token has expired
  Future<bool> isTokenExpired() async {
    final expiryString = await _secureStorage.read(key: _tokenExpiryKey);
    if (expiryString == null) return true;
    
    final expiry = DateTime.parse(expiryString);
    return DateTime.now().isAfter(expiry);
  }
  
  /// Checks if the user is authenticated (has valid tokens)
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    final isExpired = await isTokenExpired();
    
    return token != null && !isExpired;
  }
  
  /// Clears all authentication tokens (logout)
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _tokenExpiryKey);
  }
} 