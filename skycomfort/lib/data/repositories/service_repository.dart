import 'dart:async';
import 'package:skycomfort/data/models/service_model.dart';
import 'package:skycomfort/data/datasources/database_helper.dart';

class ServiceRepository {
  final DatabaseHelper _databaseHelper;
  
  ServiceRepository({required DatabaseHelper databaseHelper}) 
      : _databaseHelper = databaseHelper;
  
  /// Get all available services (entertainment and meals)
  Future<List<ServiceModel>> getServices() async {
    try {
      final db = await _databaseHelper.database;
      final data = await db.query('services', where: 'availability = 1');
      return data.map((map) => ServiceModel.fromMap(map)).toList();
    } catch (e) {
      // If database isn't set up yet, return mock data
      return _getMockServices();
    }
  }
  
  /// Get services by type (entertainment or meal)
  Future<List<ServiceModel>> getServicesByType(ServiceType type) async {
    try {
      final db = await _databaseHelper.database;
      final typeStr = type.toString().split('.').last;
      final data = await db.query(
        'services', 
        where: 'type = ? AND availability = 1',
        whereArgs: [typeStr]
      );
      return data.map((map) => ServiceModel.fromMap(map)).toList();
    } catch (e) {
      // If database isn't set up yet, return filtered mock data
      return _getMockServices().where((service) => service.type == type).toList();
    }
  }
  
  /// Save selected services for the user's current session
  Future<void> saveSelectedServices(List<ServiceModel> selectedServices, String userId) async {
    // In a real app, this would save to local database
    // For now, we're not implementing this as state will be managed in memory
  }

  // Save order to database
  Future<bool> saveOrderedServices(List<ServiceModel> services, String flightId, String seatNumber) async {
    try {
      final db = await _databaseHelper.database;
      final batch = db.batch();
      
      for (var service in services) {
        batch.insert('orders', {
          'service_id': service.id,
          'flight_id': flightId,
          'seat_number': seatNumber,
          'order_time': DateTime.now().toIso8601String(),
          'status': 'pending'
        });
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      return false;
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