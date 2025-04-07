import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// NetworkStatusService is responsible for monitoring the device's network connectivity
class NetworkStatusService {
  // Singleton pattern
  static final NetworkStatusService _instance = NetworkStatusService._internal();
  
  factory NetworkStatusService() {
    return _instance;
  }
  
  NetworkStatusService._internal() {
    _connectivity = Connectivity();
    _setupConnectivityListener();
  }
  
  late final Connectivity _connectivity;
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  /// Stream that broadcasts network connectivity changes
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  
  /// Current network connectivity status
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  
  /// Initialize the service and determine initial connectivity
  Future<void> initialize() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }
  
  /// Setup a listener for connectivity changes
  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  /// Update the connection status based on connectivity result
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;
    
    // Only emit event if status actually changed
    if (wasConnected != _isConnected) {
      _connectionStatusController.add(_isConnected);
    }
  }
  
  /// Manually check current connectivity status
  Future<bool> checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResult);
    return _isConnected;
  }
  
  /// Dispose of resources
  void dispose() {
    _connectionStatusController.close();
  }
} 