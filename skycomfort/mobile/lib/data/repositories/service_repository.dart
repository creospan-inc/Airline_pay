import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:skycomfort/data/models/service_model.dart';
import 'package:skycomfort/data/datasources/database_helper.dart';
import 'package:skycomfort/data/datasources/sync_manager.dart';
import 'package:skycomfort/data/datasources/remote/api_client.dart';
import 'package:skycomfort/data/datasources/remote/network_status_service.dart';
import 'package:skycomfort/data/datasources/remote/service_api_client.dart';
import '../models/api/api_response.dart';

/// ServiceRepository provides access to service data from both local and remote sources
class ServiceRepository {
  final DatabaseHelper _dbHelper;
  final ServiceApiClient _apiClient = ServiceApiClient();
  final NetworkStatusService _networkStatus = NetworkStatusService();
  final SyncManager _syncManager = SyncManager();
  
  // Constructor with optional databaseHelper parameter
  ServiceRepository({DatabaseHelper? databaseHelper}) 
    : _dbHelper = databaseHelper ?? DatabaseHelper.instance {
    _initialize();
  }
  
  Future<void> _initialize() async {
    await _networkStatus.initialize();
    await _syncManager.initialize();
    
    // Sync services when online
    if (_networkStatus.isConnected) {
      _syncServices();
    }
    
    // Listen for connectivity changes
    _networkStatus.connectionStatus.listen((isConnected) {
      if (isConnected) {
        _syncServices();
      }
    });
  }
  
  /// Get all available services
  Future<List<ServiceModel>> getServices() async {
    try {
      // First try to get from local database
      final List<Map<String, dynamic>> localServices = await _dbHelper.queryAllRows('services');
      
      // If we're online, try to get fresh data from API
      if (_networkStatus.isConnected) {
        try {
          final ApiResponse<List<ServiceModel>> apiResponse = await _apiClient.getServices();
          
          if (apiResponse.success && apiResponse.data != null) {
            // Update local database with fresh data
            await _updateLocalServices(apiResponse.data!);
            return apiResponse.data!;
          }
        } catch (e) {
          debugPrint('Error fetching services from API: $e');
          // Fall back to local data
        }
      }
      
      // If we have local data, use it
      if (localServices.isNotEmpty) {
        return localServices.map((map) => ServiceModel.fromMap(map)).toList();
      }
      
      // If we have no data at all, return an empty list
      return [];
    } catch (e) {
      debugPrint('Error in getServices: $e');
      return [];
    }
  }
  
  /// Get services by type
  Future<List<ServiceModel>> getServicesByType(ServiceType type) async {
    try {
      // First try to get from local database
      final List<Map<String, dynamic>> localServices = await _dbHelper.query(
        'services',
        where: 'type = ?',
        whereArgs: [type.toString().split('.').last],
      );
      
      // If we're online, try to get fresh data from API
      if (_networkStatus.isConnected) {
        try {
          final ApiResponse<List<ServiceModel>> apiResponse = await _apiClient.getServicesByType(type);
          
          if (apiResponse.success && apiResponse.data != null) {
            // We don't update local database here since getServices() already handles that
            return apiResponse.data!;
          }
        } catch (e) {
          debugPrint('Error fetching services by type from API: $e');
          // Fall back to local data
        }
      }
      
      // If we have local data, use it
      if (localServices.isNotEmpty) {
        return localServices.map((map) => ServiceModel.fromMap(map)).toList();
      }
      
      // If we have no data at all, return an empty list
      return [];
    } catch (e) {
      debugPrint('Error in getServicesByType: $e');
      return [];
    }
  }
  
  /// Get a service by ID
  Future<ServiceModel?> getServiceById(int id) async {
    try {
      // First try to get from local database
      final List<Map<String, dynamic>> localServices = await _dbHelper.query(
        'services',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      // If we're online, try to get fresh data from API
      if (_networkStatus.isConnected) {
        try {
          final ApiResponse<ServiceModel> apiResponse = await _apiClient.getServiceById(id);
          
          if (apiResponse.success && apiResponse.data != null) {
            // Update local database with fresh data
            await _updateLocalService(apiResponse.data!);
            return apiResponse.data;
          }
        } catch (e) {
          debugPrint('Error fetching service by ID from API: $e');
          // Fall back to local data
        }
      }
      
      // If we have local data, use it
      if (localServices.isNotEmpty) {
        return ServiceModel.fromMap(localServices.first);
      }
      
      // If we have no data at all, return null
      return null;
    } catch (e) {
      debugPrint('Error in getServiceById: $e');
      return null;
    }
  }
  
  /// Save a selected service (for the cart)
  Future<bool> saveSelectedService(ServiceModel service) async {
    try {
      // Update local database
      final int id = await _dbHelper.insert('services', service.toMap());
      return id > 0;
    } catch (e) {
      debugPrint('Error saving selected service: $e');
      return false;
    }
  }
  
  /// Synchronize services with remote API
  Future<void> _syncServices() async {
    try {
      final ApiResponse<List<ServiceModel>> apiResponse = await _apiClient.getServices();
      
      if (apiResponse.success && apiResponse.data != null) {
        await _updateLocalServices(apiResponse.data!);
      }
    } catch (e) {
      debugPrint('Error syncing services: $e');
    }
  }
  
  /// Update local services with data from API
  Future<void> _updateLocalServices(List<ServiceModel> services) async {
    try {
      // First delete all existing services
      await _dbHelper.delete('services', '1=1', []);
      
      // Then insert new services
      for (final service in services) {
        await _dbHelper.insert('services', service.toMap());
      }
    } catch (e) {
      debugPrint('Error updating local services: $e');
    }
  }
  
  /// Update a single local service
  Future<void> _updateLocalService(ServiceModel service) async {
    try {
      // Check if service exists
      final exists = await _dbHelper.query(
        'services',
        where: 'id = ?',
        whereArgs: [service.id],
      );
      
      if (exists.isNotEmpty) {
        // Update existing service using the helper method
        await _dbHelper.update(
          'services',
          service.toMap(),
          'id = ?',
          [service.id],
        );
      } else {
        // Insert new service
        await _dbHelper.insert('services', service.toMap());
      }
    } catch (e) {
      debugPrint('Error updating local service: $e');
    }
  }

  /// Save selected services for the user's current session
  Future<void> saveSelectedServices(List<ServiceModel> selectedServices, String userId) async {
    try {
      final db = await _dbHelper.database;
      // Clear existing selections
      await db.delete(
        'user_selections',
        where: 'user_id = ?',
        whereArgs: [userId]
      );
      
      // Save new selections
      for (var service in selectedServices) {
        await db.insert('user_selections', {
          'user_id': userId,
          'service_id': service.id,
          'selected_at': DateTime.now().toIso8601String(),
        });
        
        // Add to sync queue for server synchronization
        await _syncManager.queueForSync(
          operation: 'INSERT',
          table: 'user_selections',
          data: {
            'user_id': userId,
            'service_id': service.id,
            'selected_at': DateTime.now().toIso8601String(),
          },
        );
      }
      
      // Try to sync immediately if possible
      _syncManager.syncNow();
    } catch (e) {
      print('Error saving selected services: $e');
    }
  }

  // Save order to database
  Future<bool> saveOrderedServices(List<ServiceModel> services, String flightId, String seatNumber) async {
    try {
      final db = await _dbHelper.database;
      
      // Create a unique order ID
      final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      
      // First create the order
      final orderMap = {
        'id': orderId,
        'flight_id': flightId,
        'seat_number': seatNumber,
        'order_time': DateTime.now().toIso8601String(),
        'status': 'pending'
      };
      
      await db.insert('orders', orderMap);
      
      // Add order to sync queue
      await _syncManager.queueForSync(
        operation: 'INSERT',
        table: 'orders',
        data: orderMap,
      );
      
      // Then add each service as an order item
      for (var service in services) {
        final orderItemMap = {
          'order_id': orderId,
          'service_id': service.id,
          'price': service.price,
          'status': 'pending'
        };
        
        await db.insert('order_items', orderItemMap);
        
        // Add order item to sync queue
        await _syncManager.queueForSync(
          operation: 'INSERT',
          table: 'order_items',
          data: orderItemMap,
        );
      }
      
      // Try to sync immediately
      _syncManager.syncNow();
      
      return true;
    } catch (e) {
      print('Error saving ordered services: $e');
      return false;
    }
  }
  
  // Get a user's order history
  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      final db = await _dbHelper.database;
      
      // Get all orders for the user
      final orders = await db.query(
        'orders',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'order_time DESC'
      );
      
      List<Map<String, dynamic>> result = [];
      
      // For each order, get its items
      for (var order in orders) {
        final orderId = order['id'] as String;
        
        final items = await db.query(
          'order_items',
          where: 'order_id = ?',
          whereArgs: [orderId]
        );
        
        // Get service details for each item
        List<Map<String, dynamic>> itemsWithDetails = [];
        for (var item in items) {
          final serviceId = item['service_id'] as String;
          final serviceData = await db.query(
            'services',
            where: 'id = ?',
            whereArgs: [serviceId]
          );
          
          if (serviceData.isNotEmpty) {
            itemsWithDetails.add({
              ...item,
              'service': serviceData.first,
            });
          }
        }
        
        result.add({
          ...order,
          'items': itemsWithDetails,
        });
      }
      
      return result;
    } catch (e) {
      print('Error getting user orders: $e');
      return [];
    }
  }

  // Mock data for development
  List<ServiceModel> _getMockServices() {
    return [
      // Meals
      const ServiceModel(
        id: 'meal-1',
        title: 'Premium Chicken Meal',
        description: 'Grilled chicken breast with vegetables and rice',
        price: 15.99,
        type: ServiceType.meal,
        imageUrl: 'assets/images/meal_chicken.jpg',
      ),
      const ServiceModel(
        id: 'meal-2',
        title: 'Vegetarian Pasta',
        description: 'Fresh pasta with seasonal vegetables and pesto sauce',
        price: 12.99,
        type: ServiceType.meal,
        imageUrl: 'assets/images/meal_pasta.jpg',
      ),
      const ServiceModel(
        id: 'meal-3',
        title: 'Seafood Platter',
        description: 'Selection of premium seafood with side salad',
        price: 18.99,
        type: ServiceType.meal,
        imageUrl: 'assets/images/meal_seafood.jpg',
      ),
      
      // Beverages
      const ServiceModel(
        id: 'beverage-1',
        title: 'Premium Wine',
        description: 'Glass of premium red or white wine',
        price: 8.99,
        type: ServiceType.beverage,
        imageUrl: 'assets/images/beverage_wine.jpg',
      ),
      const ServiceModel(
        id: 'beverage-2',
        title: 'Craft Beer',
        description: 'Selection of local craft beers',
        price: 6.99,
        type: ServiceType.beverage,
        imageUrl: 'assets/images/beverage_beer.jpg',
      ),
      
      // Entertainment
      const ServiceModel(
        id: 'entertainment-1',
        title: 'Movie Pass',
        description: 'Access to premium movies not included in basic package',
        price: 9.99,
        type: ServiceType.entertainment,
        imageUrl: 'assets/images/entertainment_movies.jpg',
      ),
      const ServiceModel(
        id: 'entertainment-2',
        title: 'Premium Wi-Fi',
        description: 'High-speed internet for streaming and video calls',
        price: 14.99,
        type: ServiceType.entertainment,
        imageUrl: 'assets/images/entertainment_wifi.jpg',
      ),
      
      // Comfort items
      const ServiceModel(
        id: 'comfort-1',
        title: 'Comfort Kit',
        description: 'Includes eye mask, earplugs, and travel socks',
        price: 11.99,
        type: ServiceType.comfort,
        imageUrl: 'assets/images/comfort_kit.jpg',
      ),
      const ServiceModel(
        id: 'comfort-2',
        title: 'Premium Blanket',
        description: 'Soft, luxurious blanket for your journey',
        price: 7.99,
        type: ServiceType.comfort,
        imageUrl: 'assets/images/comfort_blanket.jpg',
      ),
    ];
  }
} 