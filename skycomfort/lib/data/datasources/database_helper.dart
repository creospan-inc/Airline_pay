import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:skycomfort/data/models/service_model.dart';

class DatabaseHelper {
  static const String _databaseName = 'skycomfort.db';
  static const int _databaseVersion = 1;
  
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
  Future<Database> get database async {
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
    );
  }
  
  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        user_id TEXT PRIMARY KEY,
        flight_number TEXT,
        seat_number TEXT,
        preferences TEXT
      )
    ''');
    
    // Services table
    await db.execute('''
      CREATE TABLE services (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        type TEXT NOT NULL,
        imageUrl TEXT,
        availability INTEGER DEFAULT 1
      )
    ''');
    
    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        order_id TEXT PRIMARY KEY,
        user_id TEXT,
        flight_id TEXT,
        seat_number TEXT,
        order_date TEXT,
        status TEXT DEFAULT 'pending',
        total_amount REAL,
        payment_transaction_id TEXT,
        FOREIGN KEY (user_id) REFERENCES users (user_id)
      )
    ''');
    
    // Order items table
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT,
        service_id TEXT,
        price REAL,
        FOREIGN KEY (order_id) REFERENCES orders (order_id),
        FOREIGN KEY (service_id) REFERENCES services (id)
      )
    ''');
    
    // Payment methods table
    await db.execute('''
      CREATE TABLE payment_methods (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        card_number TEXT,
        expiry_date TEXT,
        cardholder_name TEXT,
        card_type TEXT,
        last_four_digits TEXT,
        FOREIGN KEY (user_id) REFERENCES users (user_id)
      )
    ''');
    
    // Seed data for services
    await _seedServices(db);
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
    return await db.insert(table, row);
  }
  
  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    final db = await database;
    return await db.query(table);
  }
  
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }
  
  Future<int> update(
    String table,
    Map<String, dynamic> row,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(
      table,
      row,
      where: where,
      whereArgs: whereArgs,
    );
  }
  
  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }
} 