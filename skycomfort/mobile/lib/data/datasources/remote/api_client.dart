import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skycomfort/config/app_config.dart';
import 'package:skycomfort/data/models/service_model.dart';
import 'package:skycomfort/data/models/order_model.dart';
import 'package:skycomfort/data/models/payment_model.dart';

/// API Client for communicating with the SkyComfort backend
class ApiClient {
  final http.Client _httpClient;
  final FlutterSecureStorage _secureStorage;
  final AppConfig _appConfig;
  
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  // Singleton pattern
  static ApiClient? _instance;
  
  factory ApiClient({
    http.Client? httpClient,
    FlutterSecureStorage? secureStorage,
    AppConfig? appConfig,
  }) {
    _instance ??= ApiClient._internal(
      httpClient: httpClient ?? http.Client(),
      secureStorage: secureStorage ?? const FlutterSecureStorage(),
      appConfig: appConfig ?? AppConfig.getInstance(),
    );
    return _instance!;
  }
  
  ApiClient._internal({
    required http.Client httpClient,
    required FlutterSecureStorage secureStorage,
    required AppConfig appConfig,
  }) : 
    _httpClient = httpClient,
    _secureStorage = secureStorage,
    _appConfig = appConfig;
  
  /// Get the base URL for API requests
  String get _baseUrl => _appConfig.apiBaseUrl;
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    return token != null;
  }
  
  /// Set authentication tokens
  Future<void> setAuthTokens({
    required String accessToken, 
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }
  
  /// Clear authentication tokens
  Future<void> clearAuthTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
  
  /// Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    final responseData = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      // Save tokens
      await setAuthTokens(
        accessToken: responseData['token'],
        refreshToken: responseData['refreshToken'],
      );
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Failed to login');
    }
  }
  
  /// Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? flightId,
    String? seatNumber,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'flightId': flightId,
        'seatNumber': seatNumber,
      }),
    );
    
    final responseData = jsonDecode(response.body);
    
    if (response.statusCode == 201) {
      // Save tokens
      await setAuthTokens(
        accessToken: responseData['token'],
        refreshToken: responseData['refreshToken'],
      );
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Failed to register');
    }
  }
  
  /// Refresh authentication token
  Future<void> _refreshToken() async {
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }
    
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/auth/refresh'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'refreshToken': refreshToken,
      }),
    );
    
    final responseData = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      await setAuthTokens(
        accessToken: responseData['token'],
        refreshToken: responseData['refreshToken'],
      );
    } else {
      // Clear tokens if refresh fails
      await clearAuthTokens();
      throw Exception('Authentication expired, please login again');
    }
  }
  
  /// Get authentication headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    
    if (token == null) {
      throw Exception('No authentication token available');
    }
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  /// Perform an authenticated request with token refresh capability
  Future<http.Response> _authenticatedRequest(
    Future<http.Response> Function() requestFunction
  ) async {
    try {
      final response = await requestFunction();
      
      // If unauthorized, try to refresh token and retry
      if (response.statusCode == 401) {
        await _refreshToken();
        return await requestFunction();
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Get all available services
  Future<List<ServiceModel>> getServices() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/services'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> servicesData = responseData['data'];
      
      return servicesData
        .map((serviceData) => ServiceModel.fromMap(serviceData))
        .toList();
    } else {
      throw Exception('Failed to load services');
    }
  }
  
  /// Get services by type
  Future<List<ServiceModel>> getServicesByType(String type) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/services/type/$type'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> servicesData = responseData['data'];
      
      return servicesData
        .map((serviceData) => ServiceModel.fromMap(serviceData))
        .toList();
    } else {
      throw Exception('Failed to load services by type');
    }
  }
  
  /// Create a new order
  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> items,
    required String flightId,
    required String seatNumber,
    String? notes,
  }) async {
    final response = await _authenticatedRequest(() async {
      return await _httpClient.post(
        Uri.parse('$_baseUrl/orders'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'items': items,
          'flightId': flightId,
          'seatNumber': seatNumber,
          'notes': notes,
        }),
      );
    });
    
    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final orderData = responseData['data'];
      
      // Here we would need to convert the response to an OrderModel
      // This is a simplified implementation
      return OrderModel(
        id: orderData['id'],
        userId: orderData['userId'],
        flightId: orderData['flightId'],
        seatNumber: orderData['seatNumber'],
        items: [], // We'd need to parse the items
        totalAmount: orderData['totalAmount'] is int 
          ? (orderData['totalAmount'] as int).toDouble() 
          : orderData['totalAmount'],
        status: orderData['status'] ?? 'pending',
        createdAt: DateTime.parse(orderData['createdAt']),
        updatedAt: orderData['updatedAt'] != null 
          ? DateTime.parse(orderData['updatedAt']) 
          : null,
      );
    } else {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['message'] ?? 'Failed to create order');
    }
  }
  
  /// Process a payment
  Future<PaymentResult> processPayment({
    required String orderId,
    required String paymentMethod,
    required double amount,
    required Map<String, dynamic> paymentDetails,
  }) async {
    final response = await _authenticatedRequest(() async {
      // Generate a transaction ID if not provided in paymentDetails
      final transactionId = paymentDetails['transactionId'] ?? 'tx_${DateTime.now().millisecondsSinceEpoch}';
      final lastFourDigits = paymentDetails['lastFourDigits'] ?? '';
      final metadata = paymentDetails['metadata'] ?? {};
      
      return await _httpClient.post(
        Uri.parse('$_baseUrl/payments'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'orderId': int.parse(orderId),
          'transactionId': transactionId,
          'amount': amount,
          'paymentMethod': paymentMethod,
          'lastFourDigits': lastFourDigits,
          'metadata': metadata
        }),
      );
    });
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final paymentData = responseData['data'];
      
      // We'd need to convert the response to a PaymentResult
      // This is a simplified implementation
      return PaymentResult.fromMap({
        'transactionId': paymentData['transactionId'],
        'status': 'success',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'amount': paymentData['amount'],
        'last4Digits': paymentData['lastFourDigits'] ?? '',
      });
    } else {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['message'] ?? 'Payment processing failed');
    }
  }
  
  /// Synchronize offline data
  Future<Map<String, dynamic>> syncData(List<Map<String, dynamic>> syncItems) async {
    final response = await _authenticatedRequest(() async {
      return await _httpClient.post(
        Uri.parse('$_baseUrl/sync'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'items': syncItems,
        }),
      );
    });
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData;
    } else {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['message'] ?? 'Synchronization failed');
    }
  }
  
  /// Helper method to parse order status
  OrderStatus _parseOrderStatus(String status) {
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'paid':
        return OrderStatus.paid;
      case 'processing':
        return OrderStatus.processing;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
} 