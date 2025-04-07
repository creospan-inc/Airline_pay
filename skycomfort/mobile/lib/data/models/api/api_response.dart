import 'package:dio/dio.dart';
import 'package:skycomfort/data/models/api/api_error.dart';

/// Base class for API responses
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final ApiError? error;
  
  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });
  
  /// Create an ApiResponse from a successful response
  factory ApiResponse.success({
    required T data,
    String? message,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }
  
  /// Create an ApiResponse from an error
  factory ApiResponse.error({
    required String message,
    int? statusCode,
    String? errorCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      error: ApiError(
        message: message,
        statusCode: statusCode,
        errorCode: errorCode,
      ),
    );
  }
  
  /// Create an ApiResponse from a DioException
  factory ApiResponse.fromDioException(DioException exception) {
    final response = exception.response;
    
    // Handle specific error responses
    if (response != null) {
      try {
        final data = response.data;
        
        if (data is Map<String, dynamic>) {
          return ApiResponse<T>.error(
            message: data['message'] ?? 'An error occurred',
            statusCode: response.statusCode,
            errorCode: data['code'],
          );
        }
      } catch (_) {
        // Ignore parsing errors
      }
      
      return ApiResponse<T>.error(
        message: 'Server error: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    
    // Handle connection errors
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout) {
      return ApiResponse<T>.error(
        message: 'Connection timeout. Please check your internet connection.',
        errorCode: 'timeout',
      );
    }
    
    if (exception.type == DioExceptionType.connectionError) {
      return ApiResponse<T>.error(
        message: 'Connection error. Please check your internet connection.',
        errorCode: 'connection',
      );
    }
    
    // Generic error message
    return ApiResponse<T>.error(
      message: exception.message ?? 'An unexpected error occurred',
      errorCode: 'unknown',
    );
  }
  
  /// Create an ApiResponse from any error object
  factory ApiResponse.fromException(dynamic error) {
    return ApiResponse<T>.error(
      message: error.toString(),
      errorCode: 'exception',
    );
  }
  
  /// Parse a JSON response into an ApiResponse
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final status = json['status'] as String?;
    final success = status == 'success';
    final message = json['message'] as String?;
    
    if (success) {
      final dataJson = json['data'];
      final T data = dataJson != null 
          ? fromJson(dataJson as Map<String, dynamic>)
          : null as T;
          
      return ApiResponse<T>.success(
        data: data,
        message: message,
      );
    } else {
      return ApiResponse<T>.error(
        message: message ?? 'Unknown error',
        errorCode: json['code'] as String?,
        statusCode: json['statusCode'] as int?,
      );
    }
  }
  
  /// Parse a JSON list response into an ApiResponse
  factory ApiResponse.fromJsonList(
    Map<String, dynamic> json,
    T Function(List<dynamic>) fromJsonList,
  ) {
    final status = json['status'] as String?;
    final success = status == 'success';
    final message = json['message'] as String?;
    
    if (success) {
      final dataJson = json['data'];
      final T data = dataJson != null 
          ? fromJsonList(dataJson as List<dynamic>)
          : null as T;
          
      return ApiResponse<T>.success(
        data: data,
        message: message,
      );
    } else {
      return ApiResponse<T>.error(
        message: message ?? 'Unknown error',
        errorCode: json['code'] as String?,
        statusCode: json['statusCode'] as int?,
      );
    }
  }
} 