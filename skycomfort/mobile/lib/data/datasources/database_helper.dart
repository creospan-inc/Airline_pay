import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:skycomfort/data/models/service_model.dart';

class DatabaseHelper {
  static const String _databaseName = 'skycomfort.db';
  static const int _databaseVersion = 2; // Increased version for schema updates
  
  // Singleton pattern
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  
  // Private constructor for singleton
  DatabaseHelper._privateConstructor();
  
  // Constructor that accepts an existing database
  DatabaseHelper({Database? database}) {
    if (database != null) {
      _database = database;
    }
  }
  
  // Database getter
  Future<dynamic> get database async {
    // For web platform, return a mock database
    if (kIsWeb) {
      return _MockDatabase();
    }
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  // Initialize the database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    await _createUsersTable(db);
    await _createServicesTable(db);
    await _createOrdersTable(db);
    await _createOrderItemsTable(db);
    await _createPaymentMethodsTable(db);
    await _createSyncQueueTable(db);
    
    // Seed data for services
    await _seedServices(db);
  }
  
  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Upgrade from version 1 to 2
      // First check if sync_queue table exists
      final syncQueueExists = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='sync_queue'");
      if (syncQueueExists.isEmpty) {
        // Add SyncQueue table only if it doesn't exist
        await _createSyncQueueTable(db);
      }
      
      // Check if users table has flight_id column, if not add it
      var userTableInfo = await db.rawQuery("PRAGMA table_info(users)");
      bool hasFlightId = userTableInfo.any((col) => col['name'] == 'flight_id');
      
      if (!hasFlightId) {
        await db.execute('ALTER TABLE users ADD COLUMN flight_id TEXT');
      }
    }
    
    // Add future migrations here as needed
  }
  
  // Create users table
  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        flight_id TEXT,
        seat_number TEXT,
        name TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }
  
  // Create services table
  Future<void> _createServicesTable(Database db) async {
    await db.execute('''
      CREATE TABLE services (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        type TEXT NOT NULL,
        imageUrl TEXT,
        availability INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }
  
  // Create orders table
  Future<void> _createOrdersTable(Database db) async {
    await db.execute('''
      CREATE TABLE orders (
        order_id TEXT PRIMARY KEY,
        user_id TEXT,
        order_date TEXT NOT NULL,
        status TEXT NOT NULL,
        total_amount REAL NOT NULL,
        payment_transaction_id TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }
  
  // Create order items table
  Future<void> _createOrderItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        service_id TEXT NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (order_id),
        FOREIGN KEY (service_id) REFERENCES services (id)
      )
    ''');
  }
  
  // Create payment methods table
  Future<void> _createPaymentMethodsTable(Database db) async {
    await db.execute('''
      CREATE TABLE payment_methods (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        last_four_digits TEXT NOT NULL,
        expiry_date TEXT NOT NULL,
        cardholder_name TEXT NOT NULL,
        card_type TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }
  
  // Create sync queue table for offline/online synchronization
  Future<void> _createSyncQueueTable(Database db) async {
    // Check if the table exists first to avoid the "table already exists" error
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='sync_queue'");
    if (tables.isEmpty) {
      await db.execute('''
        CREATE TABLE sync_queue (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          entity_type TEXT NOT NULL,
          entity_id TEXT NOT NULL,
          operation TEXT NOT NULL,
          data TEXT NOT NULL,
          created_at TEXT NOT NULL,
          synced INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
  }
  
  // Seed data for services
  Future<void> _seedServices(Database db) async {
    final services = [
      {
        'id': 'meal-1',
        'title': 'Premium Chicken Meal',
        'description': 'Grilled chicken breast with vegetables and rice',
        'price': 15.99,
        'type': 'meal',
        'imageUrl': 'assets/images/meal_chicken.jpg',
        'availability': 1
      },
      {
        'id': 'meal-2',
        'title': 'Vegetarian Pasta',
        'description': 'Fresh pasta with seasonal vegetables and pesto sauce',
        'price': 12.99,
        'type': 'meal',
        'imageUrl': 'assets/images/meal_pasta.jpg',
        'availability': 1
      },
      {
        'id': 'meal-3',
        'title': 'Seafood Platter',
        'description': 'Selection of premium seafood with side salad',
        'price': 18.99,
        'type': 'meal',
        'imageUrl': 'assets/images/meal_seafood.jpg',
        'availability': 1
      },
      {
        'id': 'beverage-1',
        'title': 'Premium Wine',
        'description': 'Glass of premium red or white wine',
        'price': 8.99,
        'type': 'beverage',
        'imageUrl': 'assets/images/beverage_wine.jpg',
        'availability': 1
      },
      {
        'id': 'beverage-2',
        'title': 'Craft Beer',
        'description': 'Selection of local craft beers',
        'price': 6.99,
        'type': 'beverage',
        'imageUrl': 'assets/images/beverage_beer.jpg',
        'availability': 1
      },
      {
        'id': 'entertainment-1',
        'title': 'Movie Pass',
        'description': 'Access to premium movies not included in basic package',
        'price': 9.99,
        'type': 'entertainment',
        'imageUrl': 'assets/images/entertainment_movies.jpg',
        'availability': 1
      },
      {
        'id': 'entertainment-2',
        'title': 'Premium Wi-Fi',
        'description': 'High-speed internet for streaming and video calls',
        'price': 14.99,
        'type': 'entertainment',
        'imageUrl': 'assets/images/entertainment_wifi.jpg',
        'availability': 1
      },
      {
        'id': 'comfort-1',
        'title': 'Comfort Kit',
        'description': 'Includes eye mask, earplugs, and travel socks',
        'price': 11.99,
        'type': 'comfort',
        'imageUrl': 'assets/images/comfort_kit.jpg',
        'availability': 1
      },
      {
        'id': 'comfort-2',
        'title': 'Premium Blanket',
        'description': 'Soft, luxurious blanket for your journey',
        'price': 7.99,
        'type': 'comfort',
        'imageUrl': 'assets/images/comfort_blanket.jpg',
        'availability': 1
      },
    ];
    
    for (var service in services) {
      await db.insert('services', service);
    }
  }
  
  // Helper methods for CRUD operations
  
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    if (db is Database) {
      final id = await db.insert(table, row);
      
      // Add to sync queue for later synchronization with the server
      if (table != 'sync_queue') {
        await _addToSyncQueue(table, row['id'] ?? row['order_id'] ?? '', 'insert', row);
      }
      
      return id;
    } else {
      // For web mock
      return 1;
    }
  }
  
  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    final db = await database;
    if (db is Database) {
      return await db.query(table);
    } else {
      // For web mock
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    if (db is Database) {
      return await db.query(
        table,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
      );
    } else {
      // For web mock
      return _mockQuery(table, where, whereArgs);
    }
  }
  
  Future<int> update(
    String table,
    Map<String, dynamic> row,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    if (db is Database) {
      final count = await db.update(
        table,
        row,
        where: where,
        whereArgs: whereArgs,
      );
      
      // Add to sync queue for later synchronization with the server
      if (table != 'sync_queue' && count > 0) {
        String entityId = row['id'] ?? row['order_id'] ?? '';
        if (entityId.isEmpty && whereArgs.isNotEmpty) {
          entityId = whereArgs[0].toString();
        }
        await _addToSyncQueue(table, entityId, 'update', row);
      }
      
      return count;
    } else {
      // For web mock
      return 1;
    }
  }
  
  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    if (db is Database) {
      final count = await db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
      
      // Add to sync queue for later synchronization with the server
      if (table != 'sync_queue' && count > 0 && whereArgs.isNotEmpty) {
        String entityId = whereArgs[0].toString();
        await _addToSyncQueue(table, entityId, 'delete', {'id': entityId});
      }
      
      return count;
    } else {
      // For web mock
      return 1;
    }
  }
  
  // Add entry to sync queue for offline synchronization
  Future<void> _addToSyncQueue(String entityType, String entityId, String operation, Map<String, dynamic> data) async {
    final db = await database;
    if (db is Database) {
      await db.insert('sync_queue', {
        'entity_type': entityType,
        'entity_id': entityId,
        'operation': operation,
        'data': data.toString(), // For simplicity; in reality would use JSON encoding
        'created_at': DateTime.now().toIso8601String(),
        'synced': 0
      });
    }
  }
  
  // Add a public method for SyncManager to call
  Future<void> addToSyncQueue({
    required String operation,
    required String table,
    required String data,
  }) async {
    final db = await database;
    if (db is Database) {
      await db.insert('sync_queue', {
        'entity_type': table,
        'entity_id': '', // The entity ID will be extracted from the data
        'operation': operation,
        'data': data,
        'created_at': DateTime.now().toIso8601String(),
        'synced': 0
      });
    }
  }
  
  // Get pending sync items
  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final db = await database;
    if (db is Database) {
      return await db.query(
        'sync_queue',
        where: 'synced = ?',
        whereArgs: [0],
        orderBy: 'created_at ASC'
      );
    } else {
      return [];
    }
  }
  
  // Mark sync item as synchronized
  Future<void> markSyncItemAsSynced(int id) async {
    final db = await database;
    if (db is Database) {
      await db.update(
        'sync_queue',
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [id]
      );
    }
  }
  
  // Add method with the name SyncManager expects
  Future<void> markSyncItemAsSynchronized(int id) async {
    await markSyncItemAsSynced(id);
  }
  
  // Mock methods for web platform
  List<Map<String, dynamic>> _mockQuery(String table, String? where, List<dynamic>? whereArgs) {
    if (table == 'services') {
      var services = _getMockServices().map((s) => s.toMap()).toList();
      if (where != null && where.contains('type = ?') && whereArgs != null) {
        String typeFilter = whereArgs[0].toString();
        return services.where((s) => s['type'] == typeFilter).toList();
      }
      return services;
    }
    return [];
  }
  
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
      // Add more mock services as needed
    ];
  }
}

// Mock database for web platform
class _MockDatabase {
  // This class provides a minimal implementation that mimics a database
  // but uses in-memory storage for web platform where SQLite isn't available
} 