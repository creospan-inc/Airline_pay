import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:skycomfort/data/models/order_model.dart';
import 'package:skycomfort/data/models/service_model.dart';
import 'package:skycomfort/data/datasources/database_helper.dart';

class OrderRepository {
  final DatabaseHelper _databaseHelper;
  final _uuid = const Uuid();
  
  OrderRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;
  
  /// Create a new order from selected services
  Future<OrderModel> createOrder(List<ServiceModel> selectedServices, double totalAmount, {String? userId}) async {
    final orderId = 'SK${_uuid.v4().substring(0, 6).toUpperCase()}';
    
    final order = OrderModel(
      orderId: orderId,
      items: selectedServices,
      totalAmount: totalAmount,
      orderDate: DateTime.now(),
      status: OrderStatus.pending,
      userId: userId,
    );
    
    try {
      final db = await _databaseHelper.database;
      // Insert order into the database
      await db.insert('orders', {
        'order_id': order.orderId,
        'user_id': order.userId,
        'order_date': order.orderDate.toIso8601String(),
        'status': OrderStatus.pending.toString().split('.').last,
        'total_amount': order.totalAmount,
      });
      
      // Insert order items
      for (var item in order.items) {
        await db.insert('order_items', {
          'order_id': order.orderId,
          'service_id': item.id,
          'price': item.price,
        });
      }
    } catch (e) {
      // Silently fail for now, in real app would handle this better
      print('Failed to save order: $e');
    }
    
    return order;
  }
  
  /// Update the order status
  Future<OrderModel> updateOrderStatus(OrderModel order, OrderStatus status) async {
    final updatedOrder = order.copyWith(status: status);
    
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'orders',
        {'status': status.toString().split('.').last},
        where: 'order_id = ?',
        whereArgs: [order.orderId],
      );
    } catch (e) {
      print('Failed to update order status: $e');
    }
    
    return updatedOrder;
  }
  
  /// Mark an order as paid with transaction ID
  Future<OrderModel> markOrderAsPaid(OrderModel order, String transactionId) async {
    final updatedOrder = order.copyWith(
      status: OrderStatus.paid,
      paymentTransactionId: transactionId,
    );
    
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'orders',
        {
          'status': OrderStatus.paid.toString().split('.').last,
          'payment_transaction_id': transactionId,
        },
        where: 'order_id = ?',
        whereArgs: [order.orderId],
      );
    } catch (e) {
      print('Failed to mark order as paid: $e');
    }
    
    return updatedOrder;
  }
  
  /// Get an order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final db = await _databaseHelper.database;
      final orderMaps = await db.query(
        'orders',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
      
      if (orderMaps.isEmpty) {
        return null;
      }
      
      // Get order items
      final itemMaps = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
      
      // Get service details for each item
      final items = <ServiceModel>[];
      for (var itemMap in itemMaps) {
        final serviceId = itemMap['service_id'] as String;
        final serviceMaps = await db.query(
          'services',
          where: 'id = ?',
          whereArgs: [serviceId],
        );
        
        if (serviceMaps.isNotEmpty) {
          items.add(ServiceModel.fromMap(serviceMaps.first));
        }
      }
      
      return OrderModel.fromMap(orderMaps.first, items);
    } catch (e) {
      print('Failed to get order: $e');
      return null;
    }
  }
  
  /// Get all orders for a user
  Future<List<OrderModel>> getOrdersForUser(String userId) async {
    try {
      final db = await _databaseHelper.database;
      final orderMaps = await db.query(
        'orders',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'order_date DESC',
      );
      
      final orders = <OrderModel>[];
      for (var orderMap in orderMaps) {
        final orderId = orderMap['order_id'] as String;
        
        // Get order items for this order
        final itemMaps = await db.query(
          'order_items',
          where: 'order_id = ?',
          whereArgs: [orderId],
        );
        
        // Get service details for each item
        final items = <ServiceModel>[];
        for (var itemMap in itemMaps) {
          final serviceId = itemMap['service_id'] as String;
          final serviceMaps = await db.query(
            'services',
            where: 'id = ?',
            whereArgs: [serviceId],
          );
          
          if (serviceMaps.isNotEmpty) {
            items.add(ServiceModel.fromMap(serviceMaps.first));
          }
        }
        
        orders.add(OrderModel.fromMap(orderMap, items));
      }
      
      return orders;
    } catch (e) {
      print('Failed to get orders for user: $e');
      return [];
    }
  }
} 