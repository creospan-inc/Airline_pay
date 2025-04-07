import 'package:equatable/equatable.dart';
import 'package:skycomfort/data/models/service_model.dart';

/// Model class for shopping cart
class CartModel extends Equatable {
  final List<ServiceModel> items;
  final double totalAmount;
  
  const CartModel({
    this.items = const [],
    this.totalAmount = 0.0,
  });
  
  /// Create an empty cart
  factory CartModel.empty() => const CartModel();
  
  /// Add a service to the cart
  CartModel addItem(ServiceModel service) {
    final newItems = List<ServiceModel>.from(items);
    
    // Check if the item is already in the cart
    final existingIndex = newItems.indexWhere((item) => item.id == service.id);
    if (existingIndex == -1) {
      newItems.add(service);
    }
    
    return copyWith(
      items: newItems,
      totalAmount: _calculateTotal(newItems),
    );
  }
  
  /// Remove a service from the cart
  CartModel removeItem(String serviceId) {
    final newItems = List<ServiceModel>.from(items)
      ..removeWhere((item) => item.id == serviceId);
    
    return copyWith(
      items: newItems,
      totalAmount: _calculateTotal(newItems),
    );
  }
  
  /// Clear all items from the cart
  CartModel clearItems() {
    return const CartModel();
  }
  
  /// Toggle a service in the cart (add if not present, remove if present)
  CartModel toggleItem(ServiceModel service) {
    final isInCart = items.any((item) => item.id == service.id);
    return isInCart ? removeItem(service.id) : addItem(service);
  }
  
  /// Calculate the total amount of all items in the cart
  double _calculateTotal(List<ServiceModel> items) {
    return items.fold(0.0, (sum, item) => sum + item.price);
  }
  
  /// Create a copy with modified properties
  CartModel copyWith({
    List<ServiceModel>? items,
    double? totalAmount,
  }) {
    return CartModel(
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
  
  /// Calculate the total price of all items in the cart
  double get totalPrice => items.fold(
    0, (previous, item) => previous + item.price);
  
  /// Check if the cart contains a specific item
  bool containsItem(ServiceModel item) => items.contains(item);
  
  /// Get the number of items in the cart
  int get itemCount => items.length;
  
  /// Check if the cart is empty
  bool get isEmpty => items.isEmpty;
  
  @override
  List<Object> get props => [items, totalAmount];
} 