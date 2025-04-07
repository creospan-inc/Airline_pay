import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../models/api/api_response.dart';
import '../../models/api/api_error.dart';
import '../../models/user_model.dart';
import 'network_service.dart';
import 'token_manager.dart';

/// AuthService handles all authentication-related functionalities
class AuthService {
  final NetworkService _networkService = NetworkService();
  final TokenManager _tokenManager = TokenManager();
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }
  
  AuthService._internal();
  
  /// Login with username and password
  Future<ApiResponse<UserModel>> login(String username, String password) async {
    try {
      final response = await _networkService.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );
      
      // Save tokens
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        if (data.containsKey('accessToken') && data.containsKey('refreshToken')) {
          await _tokenManager.saveTokens(
            accessToken: data['accessToken'] as String,
            refreshToken: data['refreshToken'] as String,
            expiry: DateTime.now().add(const Duration(hours: 24)), // Default to 24 hours
          );
        }
        
        // Parse user data
        if (data.containsKey('user')) {
          return ApiResponse.success(
            UserModel.fromJson(data['user'] as Map<String, dynamic>),
            message: 'Login successful',
          );
        }
      }
      
      return ApiResponse.error(
        const ApiError(message: 'Invalid credentials or server error'),
      );
    } catch (e) {
      return ApiResponse.fromException(e);
    }
  }
  
  /// Register a new user
  Future<ApiResponse<UserModel>> register({
    required String username,
    required String password,
    required String name,
    required String email,
    required String flightId,
    required String seatNumber,
  }) async {
    try {
      final response = await _networkService.post(
        '/auth/register',
        data: {
          'username': username,
          'password': password,
          'name': name,
          'email': email,
          'flightId': flightId,
          'seatNumber': seatNumber,
        },
      );
      
      if (response.statusCode == 201 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        // Save tokens if returned with registration
        if (data.containsKey('accessToken') && data.containsKey('refreshToken')) {
          await _tokenManager.saveTokens(
            accessToken: data['accessToken'] as String,
            refreshToken: data['refreshToken'] as String,
            expiry: DateTime.now().add(const Duration(hours: 24)),
          );
        }
        
        // Parse user data
        if (data.containsKey('user')) {
          return ApiResponse.success(
            UserModel.fromJson(data['user'] as Map<String, dynamic>),
            message: 'Registration successful',
          );
        }
      }
      
      return ApiResponse.error(
        const ApiError(message: 'Registration failed'),
      );
    } catch (e) {
      return ApiResponse.fromException(e);
    }
  }
  
  /// Refresh the access token using the refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      
      if (refreshToken == null) {
        return false;
      }
      
      final response = await _networkService.post(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        if (data.containsKey('accessToken')) {
          // Save new access token
          final String newAccessToken = data['accessToken'] as String;
          final String newRefreshToken = data['refreshToken'] as String? ?? refreshToken;
          
          await _tokenManager.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
            expiry: DateTime.now().add(const Duration(hours: 24)),
          );
          
          return true;
        }
      }
      
      // If refresh failed, clear tokens
      await logout();
      return false;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      await logout();
      return false;
    }
  }
  
  /// Check if the user is currently authenticated
  Future<bool> isAuthenticated() async {
    return await _tokenManager.isAuthenticated();
  }
  
  /// Logout the user
  Future<void> logout() async {
    try {
      // Attempt to notify server about logout
      await _networkService.post('/auth/logout');
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      // Always clear tokens locally regardless of server response
      await _tokenManager.clearTokens();
    }
  }
} 