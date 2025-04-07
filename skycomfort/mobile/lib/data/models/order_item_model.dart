/// OrderItemModel represents an item in an order
class OrderItemModel {
  final int? id;
  final int? orderId;
  final int serviceId;
  final String title;
  final String description;
  final double price;
  final int quantity;
  final String type;
  final String? imageUrl;
  
  const OrderItemModel({
    this.id,
    this.orderId,
    required this.serviceId,
    required this.title,
    required this.description,
    required this.price,
    required this.quantity,
    required this.type,
    this.imageUrl,
  });
  
  /// Create a copy of this order item with updated fields
  OrderItemModel copyWith({
    int? id,
    int? orderId,
    int? serviceId,
    String? title,
    String? description,
    double? price,
    int? quantity,
    String? type,
    String? imageUrl,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      serviceId: serviceId ?? this.serviceId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
  
  /// Create an OrderItemModel from a JSON map
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int?,
      orderId: json['orderId'] as int?,
      serviceId: json['serviceId'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : json['price'] as double,
      quantity: json['quantity'] as int,
      type: json['type'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
  
  /// Convert this OrderItemModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (orderId != null) 'orderId': orderId,
      'serviceId': serviceId,
      'title': title,
      'description': description,
      'price': price,
      'quantity': quantity,
      'type': type,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
  
  /// Calculate the total price for this item (price × quantity)
  double get totalPrice => price * quantity;
  
  @override
  String toString() {
    return '$quantity × $title (\$${price.toStringAsFixed(2)})';
  }
} 