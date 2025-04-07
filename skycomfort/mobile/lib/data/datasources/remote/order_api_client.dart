import '../../models/api/api_response.dart';
import '../../models/order_model.dart';
import 'network_service.dart';

/// OrderApiClient handles all order-related API operations
class OrderApiClient {
  final NetworkService _networkService = NetworkService();
  
  // Singleton pattern
  static final OrderApiClient _instance = OrderApiClient._internal();
  
  factory OrderApiClient() {
    return _instance;
  }
  
  OrderApiClient._internal();
  
  /// Create a new order
  Future<ApiResponse<OrderModel>> createOrder(OrderModel order) async {
    try {
      final response = await _networkService.post(
        '/orders',
        data: order.toJson(),
      );
      
      if (response.statusCode == 201 && response.data != null) {
        final orderJson = response.data['order'] as Map<String, dynamic>;
        final createdOrder = OrderModel.fromJson(orderJson);
        
        return ApiResponse.success(
          data: createdOrder,
          message: 'Order created successfully',
        );
      }
      
      return ApiResponse<OrderModel>.error(message: 'Failed to create order');
    } catch (e) {
      return ApiResponse<OrderModel>.error(message: e.toString());
    }
  }
  
  /// Get user's orders
  Future<ApiResponse<List<OrderModel>>> getUserOrders() async {
    try {
      final response = await _networkService.get('/orders');
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> ordersJson = response.data['orders'] as List<dynamic>;
        final orders = ordersJson
            .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        return ApiResponse.success(data: orders);
      }
      
      return ApiResponse<List<OrderModel>>.error(message: 'Failed to fetch orders');
    } catch (e) {
      return ApiResponse<List<OrderModel>>.error(message: e.toString());
    }
  }
  
  /// Get an order by ID
  Future<ApiResponse<OrderModel>> getOrderById(int orderId) async {
    try {
      final response = await _networkService.get('/orders/$orderId');
      
      if (response.statusCode == 200 && response.data != null) {
        final orderJson = response.data['order'] as Map<String, dynamic>;
        final order = OrderModel.fromJson(orderJson);
        
        return ApiResponse.success(data: order);
      }
      
      return ApiResponse<OrderModel>.error(message: 'Failed to fetch order');
    } catch (e) {
      return ApiResponse<OrderModel>.error(message: e.toString());
    }
  }
  
  /// Update an order's status
  Future<ApiResponse<OrderModel>> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await _networkService.patch(
        '/orders/$orderId/status',
        data: {'status': status},
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final orderJson = response.data['order'] as Map<String, dynamic>;
        final updatedOrder = OrderModel.fromJson(orderJson);
        
        return ApiResponse.success(
          data: updatedOrder,
          message: 'Order status updated successfully',
        );
      }
      
      return ApiResponse<OrderModel>.error(message: 'Failed to update order status');
    } catch (e) {
      return ApiResponse<OrderModel>.error(message: e.toString());
    }
  }
  
  /// Cancel an order
  Future<ApiResponse<bool>> cancelOrder(int orderId) async {
    try {
      final response = await _networkService.delete('/orders/$orderId');
      
      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: true,
          message: 'Order cancelled successfully',
        );
      }
      
      return ApiResponse<bool>.error(message: 'Failed to cancel order');
    } catch (e) {
      return ApiResponse<bool>.error(message: e.toString());
    }
  }
} 