import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../datasources/database_helper.dart';
import '../datasources/remote/network_service.dart';
import '../datasources/remote/network_status_service.dart';

/// SyncManager is responsible for synchronizing local data with the remote API
class SyncManager {
  // Singleton pattern
  static final SyncManager _instance = SyncManager._internal();
  
  factory SyncManager() {
    return _instance;
  }
  
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NetworkService _networkService = NetworkService();
  final NetworkStatusService _networkStatus = NetworkStatusService();
  
  Timer? _syncTimer;
  bool _isSyncing = false;
  
  SyncManager._internal() {
    _setupNetworkListener();
  }
  
  /// Initialize the sync manager
  Future<void> initialize() async {
    await _networkStatus.initialize();
    _startPeriodicSync();
  }
  
  /// Set up a listener for network status changes
  void _setupNetworkListener() {
    _networkStatus.connectionStatus.listen((isConnected) {
      if (isConnected) {
        // When connection is restored, try to sync immediately
        syncNow();
      }
    });
  }
  
  /// Start periodic background synchronization
  void _startPeriodicSync() {
    // Sync every 15 minutes
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      syncNow();
    });
  }
  
  /// Trigger immediate synchronization
  Future<bool> syncNow() async {
    if (_isSyncing || !_networkStatus.isConnected) {
      return false;
    }
    
    _isSyncing = true;
    bool success = false;
    
    try {
      // Process all pending sync items in the queue
      final pendingSyncItems = await _dbHelper.getPendingSyncItems();
      
      if (pendingSyncItems.isEmpty) {
        _isSyncing = false;
        return true;
      }
      
      for (final syncItem in pendingSyncItems) {
        try {
          await _processSyncItem(syncItem);
          await _dbHelper.markSyncItemAsSynchronized(syncItem['id'] as int);
        } catch (e) {
          // Log sync error but continue with next item
          debugPrint('Error processing sync item ${syncItem['id']}: $e');
        }
      }
      
      success = true;
    } catch (e) {
      debugPrint('Sync error: $e');
      success = false;
    } finally {
      _isSyncing = false;
    }
    
    return success;
  }
  
  /// Process an individual sync item
  Future<void> _processSyncItem(Map<String, dynamic> syncItem) async {
    final String operation = syncItem['operation'] as String;
    final String table = syncItem['table'] as String;
    final Map<String, dynamic> data = jsonDecode(syncItem['data'] as String);
    
    String endpoint;
    switch (table) {
      case 'users':
        endpoint = '/users';
        break;
      case 'orders':
        endpoint = '/orders';
        break;
      case 'order_items':
        endpoint = '/orders/${data['order_id']}/items';
        break;
      case 'payment_methods':
        endpoint = '/payment-methods';
        break;
      default:
        throw Exception('Unknown table for synchronization: $table');
    }
    
    switch (operation) {
      case 'INSERT':
        await _networkService.post(endpoint, data: data);
        break;
      case 'UPDATE':
        await _networkService.put('$endpoint/${data['id']}', data: data);
        break;
      case 'DELETE':
        await _networkService.delete('$endpoint/${data['id']}');
        break;
      default:
        throw Exception('Unknown operation for synchronization: $operation');
    }
  }
  
  /// Queue a data change for synchronization
  Future<void> queueForSync({
    required String operation,
    required String table,
    required Map<String, dynamic> data,
  }) async {
    await _dbHelper.addToSyncQueue(
      operation: operation,
      table: table,
      data: jsonEncode(data),
    );
    
    // Try to sync immediately if online
    if (_networkStatus.isConnected) {
      syncNow();
    }
  }
  
  /// Get the current sync status
  bool get isSyncing => _isSyncing;
  
  /// Dispose of resources
  void dispose() {
    _syncTimer?.cancel();
  }
} 