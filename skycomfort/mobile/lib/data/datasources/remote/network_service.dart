import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:skycomfort/config/app_config.dart';

/// Network service for handling API requests using Dio
class NetworkService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;
  
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  // Singleton pattern
  static NetworkService? _instance;
  
  factory NetworkService({
    Dio? dio,
    FlutterSecureStorage? secureStorage,
    Logger? logger,
    AppConfig? appConfig,
  }) {
    _instance ??= NetworkService._internal(
      dio: dio ?? Dio(),
      secureStorage: secureStorage ?? const FlutterSecureStorage(),
      logger: logger ?? Logger(),
      appConfig: appConfig ?? AppConfig.getInstance(),
    );
    return _instance!;
  }
  
  NetworkService._internal({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
    required Logger logger,
    required AppConfig appConfig,
  }) : 
    _dio = dio,
    _secureStorage = secureStorage,
    _logger = logger {
    // Configure Dio instance
    _dio.options.baseUrl = appConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.contentType = Headers.jsonContentType;
    _dio.options.responseType = ResponseType.json;
    
    // Add interceptors
    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createLogInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());
  }
  
  /// Create an interceptor for authentication
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add token to request if available
        final token = await _secureStorage.read(key: _accessTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle token refresh if 401 error
        if (error.response?.statusCode == 401) {
          try {
            final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
            if (refreshToken != null) {
              // Try to refresh the token
              final newTokens = await _refreshToken(refreshToken);
              
              // Retry the request with the new token
              error.requestOptions.headers['Authorization'] = 'Bearer ${newTokens['token']}';
              
              // Create a new request with the updated header
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          } catch (e) {
            // Clear tokens if refresh fails
            await _clearTokens();
            _logger.e('Token refresh failed: ${e.toString()}');
          }
        }
        return handler.next(error);
      },
    );
  }
  
  /// Create an interceptor for logging
  Interceptor _createLogInterceptor() {
    return LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (object) {
        _logger.d(object.toString());
      },
    );
  }
  
  /// Create an interceptor for error handling
  Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        // Transform Dio errors to more user-friendly errors
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: 'Connection timeout. Please check your internet connection.',
              type: error.type,
            ),
          );
        }
        
        if (error.type == DioExceptionType.connectionError) {
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: 'Connection error. Please check your internet connection.',
              type: error.type,
            ),
          );
        }
        
        if (error.error is SocketException) {
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: 'No internet connection.',
              type: error.type,
            ),
          );
        }
        
        return handler.next(error);
      },
    );
  }
  
  /// Refresh authentication token
  Future<Map<String, dynamic>> _refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: {
        'refreshToken': refreshToken,
      },
    );
    
    final data = response.data;
    
    // Save new tokens
    await _secureStorage.write(key: _accessTokenKey, value: data['token']);
    await _secureStorage.write(key: _refreshTokenKey, value: data['refreshToken']);
    
    return data;
  }
  
  /// Clear authentication tokens
  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
  
  /// Set authentication tokens
  Future<void> setTokens({required String accessToken, required String refreshToken}) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    return token != null;
  }
  
  /// Get method
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      _logger.e('GET $path failed: ${e.toString()}');
      rethrow;
    }
  }
  
  /// Post method
  Future<Response> post(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      _logger.e('POST $path failed: ${e.toString()}');
      rethrow;
    }
  }
  
  /// Put method
  Future<Response> put(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      _logger.e('PUT $path failed: ${e.toString()}');
      rethrow;
    }
  }
  
  /// Patch method
  Future<Response> patch(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      _logger.e('PATCH $path failed: ${e.toString()}');
      rethrow;
    }
  }
  
  /// Delete method
  Future<Response> delete(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      _logger.e('DELETE $path failed: ${e.toString()}');
      rethrow;
    }
  }
} 