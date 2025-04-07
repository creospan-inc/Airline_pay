import 'package:skycomfort/data/models/service_model.dart';
import 'order_item_model.dart';

/// Model for an order
class OrderModel {
  final int? id;
  final String userId;
  final String flightId;
  final String seatNumber;
  final List<OrderItemModel> items;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  const OrderModel({
    this.id,
    required this.userId,
    required this.flightId,
    required this.seatNumber,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
  });
  
  /// Create a copy of this order with updated fields
  OrderModel copyWith({
    int? id,
    String? userId,
    String? flightId,
    String? seatNumber,
    List<OrderItemModel>? items,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      flightId: flightId ?? this.flightId,
      seatNumber: seatNumber ?? this.seatNumber,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Create an OrderModel from a JSON map
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int?,
      userId: json['userId'] as String,
      flightId: json['flightId'] as String,
      seatNumber: json['seatNumber'] as String,
      items: json.containsKey('items') && json['items'] != null
          ? (json['items'] as List<dynamic>)
              .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      totalAmount: json['totalAmount'] is int
          ? (json['totalAmount'] as int).toDouble()
          : json['totalAmount'] as double,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
  
  /// Convert this OrderModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'flightId': flightId,
      'seatNumber': seatNumber,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
  
  /// Calculate total from items
  double calculateTotal() {
    return items.fold(0, (total, item) => total + (item.price * item.quantity));
  }
  
  @override
  String toString() {
    return 'Order #${id ?? 'New'} - $status - \$${totalAmount.toStringAsFixed(2)}';
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