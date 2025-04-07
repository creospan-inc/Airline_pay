import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  
  // Database reference
  Database? _database;
  
  // Private constructor
  DatabaseHelper._internal();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // Initialize the database
    _database = await _initDatabase();
    return _database!;
  }
  
  // Initialize the database
  Future<Database> _initDatabase() async {
    // Get the database path
    String path = join(await getDatabasesPath(), 'skycomfort.db');
    
    // Open/create the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }
  
  // Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        user_id TEXT PRIMARY KEY,
        flight_number TEXT,
        seat_number TEXT,
        preferences TEXT
      )
    ''');
    
    // Create catalog_items table
    await db.execute('''
      CREATE TABLE catalog_items (
        item_id TEXT PRIMARY KEY,
        type TEXT,
        name TEXT,
        description TEXT,
        price REAL,
        image_path TEXT,
        availability INTEGER
      )
    ''');
    
    // Create orders table
    await db.execute('''
      CREATE TABLE orders (
        order_id TEXT PRIMARY KEY,
        user_id TEXT,
        order_date INTEGER,
        status TEXT,
        total_amount REAL,
        FOREIGN KEY (user_id) REFERENCES users (user_id)
      )
    ''');
    
    // Create order_items table
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT,
        item_id TEXT,
        quantity INTEGER,
        price REAL,
        FOREIGN KEY (order_id) REFERENCES orders (order_id),
        FOREIGN KEY (item_id) REFERENCES catalog_items (item_id)
      )
    ''');
    
    // Create payment_methods table
    await db.execute('''
      CREATE TABLE payment_methods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        card_number TEXT,
        expiry_date TEXT,
        cardholder_name TEXT,
        card_type TEXT,
        last_four_digits TEXT,
        FOREIGN KEY (user_id) REFERENCES users (user_id)
      )
    ''');
  }
  
  // Insert a user
  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }
  
  // Update a user
  Future<int> updateUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.update(
      'users',
      user,
      where: 'user_id = ?',
      whereArgs: [user['user_id']],
    );
  }
  
  // Get a user by ID
  Future<Map<String, dynamic>?> getUser(String userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
  
  // Insert a catalog item
  Future<int> insertCatalogItem(Map<String, dynamic> item) async {
    Database db = await database;
    return await db.insert('catalog_items', item);
  }
  
  // Get all catalog items
  Future<List<Map<String, dynamic>>> getAllCatalogItems() async {
    Database db = await database;
    return await db.query('catalog_items');
  }
  
  // Get catalog items by type
  Future<List<Map<String, dynamic>>> getCatalogItemsByType(String type) async {
    Database db = await database;
    return await db.query(
      'catalog_items',
      where: 'type = ?',
      whereArgs: [type],
    );
  }
  
  // Insert an order
  Future<int> insertOrder(Map<String, dynamic> order) async {
    Database db = await database;
    return await db.insert('orders', order);
  }
  
  // Insert order items
  Future<int> insertOrderItem(Map<String, dynamic> orderItem) async {
    Database db = await database;
    return await db.insert('order_items', orderItem);
  }
  
  // Get orders by user ID
  Future<List<Map<String, dynamic>>> getOrdersByUserId(String userId) async {
    Database db = await database;
    return await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
  
  // Get order items by order ID
  Future<List<Map<String, dynamic>>> getOrderItemsByOrderId(String orderId) async {
    Database db = await database;
    return await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }
  
  // Get order details with items
  Future<Map<String, dynamic>> getOrderWithItems(String orderId) async {
    Database db = await database;
    
    // Get order
    List<Map<String, dynamic>> orderMaps = await db.query(
      'orders',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    
    if (orderMaps.isEmpty) {
      throw Exception('Order not found');
    }
    
    Map<String, dynamic> order = orderMaps.first;
    
    // Get order items
    List<Map<String, dynamic>> orderItems = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    
    // Get item details for each order item
    List<Map<String, dynamic>> itemsWithDetails = [];
    for (var item in orderItems) {
      String itemId = item['item_id'] as String;
      List<Map<String, dynamic>> itemDetails = await db.query(
        'catalog_items',
        where: 'item_id = ?',
        whereArgs: [itemId],
      );
      
      if (itemDetails.isNotEmpty) {
        Map<String, dynamic> combinedItem = {
          ...item,
          'details': itemDetails.first,
        };
        itemsWithDetails.add(combinedItem);
      }
    }
    
    // Add items to order
    order['items'] = itemsWithDetails;
    
    return order;
  }
  
  // Insert a payment method
  Future<int> insertPaymentMethod(Map<String, dynamic> paymentMethod) async {
    Database db = await database;
    return await db.insert('payment_methods', paymentMethod);
  }
  
  // Get payment methods by user ID
  Future<List<Map<String, dynamic>>> getPaymentMethodsByUserId(String userId) async {
    Database db = await database;
    return await db.query(
      'payment_methods',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
  
  // Delete a payment method
  Future<int> deletePaymentMethod(int id) async {
    Database db = await database;
    return await db.delete(
      'payment_methods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Insert demo data for testing
  Future<void> insertDemoData() async {
    Database db = await database;
    
    // Insert demo user
    await db.insert('users', {
      'user_id': 'user123',
      'flight_number': 'AB123',
      'seat_number': '12A',
      'preferences': '{"language":"en","theme":"light"}',
    });
    
    // Insert demo catalog items
    await db.insert('catalog_items', {
      'item_id': 'ent1',
      'type': 'entertainment',
      'name': 'Movie: Inception',
      'description': 'A thief who steals corporate secrets through the use of dream-sharing technology.',
      'price': 12.99,
      'image_path': 'assets/images/inception.jpg',
      'availability': 1,
    });
    
    await db.insert('catalog_items', {
      'item_id': 'ent2',
      'type': 'entertainment',
      'name': 'Movie: The Dark Knight',
      'description': 'Batman fights against the criminal mastermind known as the Joker.',
      'price': 11.99,
      'image_path': 'assets/images/dark_knight.jpg',
      'availability': 1,
    });
    
    await db.insert('catalog_items', {
      'item_id': 'meal1',
      'type': 'meal',
      'name': 'Chicken Pasta',
      'description': 'Grilled chicken with pasta and creamy sauce.',
      'price': 15.99,
      'image_path': 'assets/images/chicken_pasta.jpg',
      'availability': 1,
    });
    
    await db.insert('catalog_items', {
      'item_id': 'meal2',
      'type': 'meal',
      'name': 'Vegetarian Stir Fry',
      'description': 'Fresh vegetables stir-fried with tofu and rice.',
      'price': 13.99,
      'image_path': 'assets/images/stir_fry.jpg',
      'availability': 1,
    });
  }
} 