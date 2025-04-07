import 'package:skycomfort/data/models/service_model.dart';

/// Model for an order
class OrderModel {
  final String orderId;
  final List<ServiceModel> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;
  final String? userId;
  final String? paymentTransactionId;
  
  OrderModel({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.status = OrderStatus.pending,
    this.userId,
    this.paymentTransactionId,
  });
  
  /// Create an OrderModel from a map (for database operations)
  factory OrderModel.fromMap(Map<String, dynamic> map, List<ServiceModel> orderItems) {
    return OrderModel(
      orderId: map['order_id'] as String,
      items: orderItems,
      totalAmount: map['total_amount'] as double,
      orderDate: DateTime.fromMillisecondsSinceEpoch(map['order_date'] as int),
      status: _getStatusFromString(map['status'] as String),
      userId: map['user_id'] as String?,
      paymentTransactionId: map['payment_transaction_id'] as String?,
    );
  }
  
  /// Convert OrderModel to a map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'total_amount': totalAmount,
      'order_date': orderDate.millisecondsSinceEpoch,
      'status': _getStringFromStatus(status),
      'user_id': userId,
      'payment_transaction_id': paymentTransactionId,
    };
  }
  
  /// Create a copy of the model with updated fields
  OrderModel copyWith({
    String? orderId,
    List<ServiceModel>? items,
    double? totalAmount,
    DateTime? orderDate,
    OrderStatus? status,
    String? userId,
    String? paymentTransactionId,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
    );
  }
  
  /// Update the order status
  OrderModel updateStatus(OrderStatus newStatus) {
    return copyWith(status: newStatus);
  }
  
  /// Mark the order as paid
  OrderModel markAsPaid(String transactionId) {
    return copyWith(
      status: OrderStatus.paid,
      paymentTransactionId: transactionId,
    );
  }
  
  /// Mark the order as delivered
  OrderModel markAsDelivered() {
    return copyWith(status: OrderStatus.delivered);
  }
  
  /// Helper method to convert string to OrderStatus
  static OrderStatus _getStatusFromString(String status) {
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
  
  /// Helper method to convert OrderStatus to string
  static String _getStringFromStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.paid:
        return 'paid';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }
}

/// Enum for order status
enum OrderStatus {
  pending,
  paid,
  processing,
  delivered,
  cancelled,
} 