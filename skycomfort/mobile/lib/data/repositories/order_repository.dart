import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:skycomfort/data/models/order_model.dart';
import 'package:skycomfort/data/models/order_item_model.dart';
import 'package:skycomfort/data/models/service_model.dart';
import 'package:skycomfort/data/datasources/database_helper.dart';

class OrderRepository {
  final DatabaseHelper _databaseHelper;
  final _uuid = const Uuid();
  
  OrderRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;
  
  /// Create a new order from selected services
  Future<OrderModel> createOrder(List<OrderItemModel> items, double totalAmount, {
    String userId = "user123",
    String flightId = "FL123", 
    String seatNumber = "A1"
  }) async {
    final order = OrderModel(
      userId: userId,
      flightId: flightId,
      seatNumber: seatNumber,
      items: items,
      totalAmount: totalAmount,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    
    try {
      final db = await _databaseHelper.database;
      // Insert order into the database
      final orderId = await db.insert('orders', {
        'user_id': order.userId,
        'flight_id': order.flightId,
        'seat_number': order.seatNumber,
        'status': order.status,
        'total_amount': order.totalAmount,
        'created_at': order.createdAt.toIso8601String(),
      });
      
      // Insert order items
      for (var item in order.items) {
        await db.insert('order_items', {
          'order_id': orderId,
          'service_id': item.serviceId,
          'title': item.title,
          'description': item.description,
          'price': item.price,
          'quantity': item.quantity,
          'type': item.type,
          'image_url': item.imageUrl,
        });
      }
      
      return order.copyWith(id: orderId);
    } catch (e) {
      // Silently fail for now, in real app would handle this better
      print('Failed to save order: $e');
      return order;
    }
  }
  
  /// Update the order status
  Future<OrderModel> updateOrderStatus(OrderModel order, String status) async {
    final updatedOrder = order.copyWith(status: status);
    
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'orders',
        {'status': status},
        where: 'id = ?',
        whereArgs: [order.id],
      );
    } catch (e) {
      print('Failed to update order status: $e');
    }
    
    return updatedOrder;
  }
  
  /// Get an order by ID
  Future<OrderModel?> getOrderById(int orderId) async {
    try {
      final db = await _databaseHelper.database;
      final orderMaps = await db.query(
        'orders',
        where: 'id = ?',
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
      
      // Convert to OrderItemModel objects
      final items = itemMaps.map((itemMap) => OrderItemModel(
        id: itemMap['id'] as int?,
        orderId: itemMap['order_id'] as int?,
        serviceId: itemMap['service_id'] as int,
        title: itemMap['title'] as String,
        description: itemMap['description'] as String,
        price: itemMap['price'] as double,
        quantity: itemMap['quantity'] as int,
        type: itemMap['type'] as String,
        imageUrl: itemMap['image_url'] as String?,
      )).toList();
      
      // Create the order model from the database data
      return OrderModel(
        id: orderMaps.first['id'] as int?,
        userId: orderMaps.first['user_id'] as String,
        flightId: orderMaps.first['flight_id'] as String,
        seatNumber: orderMaps.first['seat_number'] as String,
        items: items,
        totalAmount: orderMaps.first['total_amount'] as double,
        status: orderMaps.first['status'] as String,
        createdAt: DateTime.parse(orderMaps.first['created_at'] as String),
        updatedAt: orderMaps.first['updated_at'] != null 
          ? DateTime.parse(orderMaps.first['updated_at'] as String) 
          : null,
      );
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
        orderBy: 'created_at DESC',
      );
      
      final orders = <OrderModel>[];
      for (var orderMap in orderMaps) {
        final orderId = orderMap['id'] as int;
        
        // Get order items for this order
        final itemMaps = await db.query(
          'order_items',
          where: 'order_id = ?',
          whereArgs: [orderId],
        );
        
        // Convert to OrderItemModel objects
        final items = itemMaps.map((itemMap) => OrderItemModel(
          id: itemMap['id'] as int?,
          orderId: itemMap['order_id'] as int?,
          serviceId: itemMap['service_id'] as int,
          title: itemMap['title'] as String,
          description: itemMap['description'] as String,
          price: itemMap['price'] as double,
          quantity: itemMap['quantity'] as int,
          type: itemMap['type'] as String,
          imageUrl: itemMap['image_url'] as String?,
        )).toList();
        
        // Create the order model
        orders.add(OrderModel(
          id: orderMap['id'] as int?,
          userId: orderMap['user_id'] as String,
          flightId: orderMap['flight_id'] as String,
          seatNumber: orderMap['seat_number'] as String,
          items: items,
          totalAmount: orderMap['total_amount'] as double,
          status: orderMap['status'] as String,
          createdAt: DateTime.parse(orderMap['created_at'] as String),
          updatedAt: orderMap['updated_at'] != null 
            ? DateTime.parse(orderMap['updated_at'] as String) 
            : null,
        ));
      }
      
      return orders;
    } catch (e) {
      print('Failed to get orders for user: $e');
      return [];
    }
  }
} 