import 'package:equatable/equatable.dart';

enum ServiceType {
  meal,
  beverage,
  entertainment,
  comfort
}

/// Model class for in-flight services (meals and entertainment)
class ServiceModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final ServiceType type;
  final String? imageUrl;
  final bool availability;
  
  const ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.type,
    this.imageUrl,
    this.availability = true,
  });
   
  @override
  List<Object?> get props => [id, title, description, price, type, imageUrl, availability];
  
  /// Create a ServiceModel from a map (for database operations)
  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      price: map['price'],
      type: _parseServiceType(map['type']),
      imageUrl: map['imageUrl'],
      availability: map['availability'] == 1,
    );
  }
  
  /// Convert ServiceModel to a map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
      'availability': availability ? 1 : 0,
    };
  }

  static ServiceType _parseServiceType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'meal':
        return ServiceType.meal;
      case 'beverage':
        return ServiceType.beverage;
      case 'entertainment':
        return ServiceType.entertainment;
      case 'comfort':
        return ServiceType.comfort;
      default:
        return ServiceType.entertainment;
    }
  }
  
  /// Create a copy of the model with updated fields
  ServiceModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    ServiceType? type,
    String? imageUrl,
    bool? availability,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      availability: availability ?? this.availability,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceModel && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
} 