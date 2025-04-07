import '../../models/api/api_response.dart';
import '../../models/payment_model.dart';
import 'network_service.dart';

/// PaymentApiClient handles all payment-related API operations
class PaymentApiClient {
  final NetworkService _networkService = NetworkService();
  
  // Singleton pattern
  static final PaymentApiClient _instance = PaymentApiClient._internal();
  
  factory PaymentApiClient() {
    return _instance;
  }
  
  PaymentApiClient._internal();
  
  /// Process a payment for an order
  Future<ApiResponse<PaymentModel>> processPayment({
    required int orderId,
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      final response = await _networkService.post(
        '/payments',
        data: {
          'orderId': orderId,
          ...paymentDetails,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final paymentJson = response.data['payment'] as Map<String, dynamic>;
        final payment = PaymentModel.fromJson(paymentJson);
        
        return ApiResponse.success(
          data: payment,
          message: 'Payment processed successfully',
        );
      }
      
      return ApiResponse.error(message: 'Failed to process payment');
    } catch (e) {
      return ApiResponse<PaymentModel>.error(message: e.toString());
    }
  }
  
  /// Get payment methods available to the user
  Future<ApiResponse<List<Map<String, dynamic>>>> getPaymentMethods() async {
    try {
      final response = await _networkService.get('/payments/methods');
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> methodsJson = response.data['methods'] as List<dynamic>;
        final methods = methodsJson.cast<Map<String, dynamic>>();
        
        return ApiResponse.success(data: methods);
      }
      
      return ApiResponse<List<Map<String, dynamic>>>.error(message: 'Failed to fetch payment methods');
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>.error(message: e.toString());
    }
  }
  
  /// Get payment by ID
  Future<ApiResponse<PaymentModel>> getPaymentById(int paymentId) async {
    try {
      final response = await _networkService.get('/payments/$paymentId');
      
      if (response.statusCode == 200 && response.data != null) {
        final paymentJson = response.data['payment'] as Map<String, dynamic>;
        final payment = PaymentModel.fromJson(paymentJson);
        
        return ApiResponse.success(data: payment);
      }
      
      return ApiResponse<PaymentModel>.error(message: 'Failed to fetch payment');
    } catch (e) {
      return ApiResponse<PaymentModel>.error(message: e.toString());
    }
  }
  
  /// Get all payments for a specific order
  Future<ApiResponse<List<PaymentModel>>> getPaymentsByOrderId(int orderId) async {
    try {
      final response = await _networkService.get('/payments', queryParameters: {'orderId': orderId});
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> paymentsJson = response.data['payments'] as List<dynamic>;
        final payments = paymentsJson
            .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        return ApiResponse.success(data: payments);
      }
      
      return ApiResponse<List<PaymentModel>>.error(message: 'Failed to fetch payments for order');
    } catch (e) {
      return ApiResponse<List<PaymentModel>>.error(message: e.toString());
    }
  }
  
  /// Refund a payment
  Future<ApiResponse<PaymentModel>> refundPayment(int paymentId) async {
    try {
      final response = await _networkService.post('/payments/$paymentId/refund');
      
      if (response.statusCode == 200 && response.data != null) {
        final paymentJson = response.data['payment'] as Map<String, dynamic>;
        final payment = PaymentModel.fromJson(paymentJson);
        
        return ApiResponse.success(
          data: payment,
          message: 'Payment refunded successfully',
        );
      }
      
      return ApiResponse<PaymentModel>.error(message: 'Failed to refund payment');
    } catch (e) {
      return ApiResponse<PaymentModel>.error(message: e.toString());
    }
  }
} 