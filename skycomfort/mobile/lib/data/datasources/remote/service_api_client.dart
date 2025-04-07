import '../../models/api/api_response.dart';
import '../../models/service_model.dart';
import 'network_service.dart';

/// ServiceApiClient handles all service-related API operations
class ServiceApiClient {
  final NetworkService _networkService = NetworkService();
  
  // Singleton pattern
  static final ServiceApiClient _instance = ServiceApiClient._internal();
  
  factory ServiceApiClient() {
    return _instance;
  }
  
  ServiceApiClient._internal();
  
  /// Fetch all available services
  Future<ApiResponse<List<ServiceModel>>> getServices() async {
    try {
      final response = await _networkService.get('/services');
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> servicesJson = response.data['services'] as List<dynamic>;
        final services = servicesJson
            .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        return ApiResponse.success(data: services);
      }
      
      return ApiResponse<List<ServiceModel>>.error(message: 'Failed to fetch services');
    } catch (e) {
      return ApiResponse<List<ServiceModel>>.error(message: e.toString());
    }
  }
  
  /// Fetch services by type
  Future<ApiResponse<List<ServiceModel>>> getServicesByType(ServiceType type) async {
    try {
      final response = await _networkService.get(
        '/services',
        queryParameters: {'type': type.toString().split('.').last},
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> servicesJson = response.data['services'] as List<dynamic>;
        final services = servicesJson
            .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        return ApiResponse.success(data: services);
      }
      
      return ApiResponse<List<ServiceModel>>.error(message: 'Failed to fetch services by type');
    } catch (e) {
      return ApiResponse<List<ServiceModel>>.error(message: e.toString());
    }
  }
  
  /// Fetch a single service by ID
  Future<ApiResponse<ServiceModel>> getServiceById(int id) async {
    try {
      final response = await _networkService.get('/services/$id');
      
      if (response.statusCode == 200 && response.data != null) {
        final serviceJson = response.data['service'] as Map<String, dynamic>;
        final service = ServiceModel.fromJson(serviceJson);
        
        return ApiResponse.success(data: service);
      }
      
      return ApiResponse<ServiceModel>.error(message: 'Failed to fetch service');
    } catch (e) {
      return ApiResponse<ServiceModel>.error(message: e.toString());
    }
  }
  
  /// Check availability of a service
  Future<ApiResponse<bool>> checkServiceAvailability(int serviceId) async {
    try {
      final response = await _networkService.get('/services/$serviceId/availability');
      
      if (response.statusCode == 200 && response.data != null) {
        final isAvailable = response.data['available'] as bool;
        
        return ApiResponse.success(data: isAvailable);
      }
      
      return ApiResponse<bool>.error(message: 'Failed to check service availability');
    } catch (e) {
      return ApiResponse<bool>.error(message: e.toString());
    }
  }
} 