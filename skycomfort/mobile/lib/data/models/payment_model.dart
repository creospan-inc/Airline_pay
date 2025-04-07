import 'package:equatable/equatable.dart';

/// PaymentModel represents a payment transaction
class PaymentModel {
  final int? id;
  final int orderId;
  final double amount;
  final String status;
  final String paymentMethod;
  final String? transactionId;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  
  const PaymentModel({
    this.id,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    this.metadata,
    required this.timestamp,
  });
  
  /// Create a copy of this payment with updated fields
  PaymentModel copyWith({
    int? id,
    int? orderId,
    double? amount,
    String? status,
    String? paymentMethod,
    String? transactionId,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
    );
  }
  
  /// Create a PaymentModel from a JSON map
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int?,
      orderId: json['orderId'] as int,
      amount: json['amount'] is int
          ? (json['amount'] as int).toDouble()
          : json['amount'] as double,
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String,
      transactionId: json['transactionId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
  
  /// Convert this PaymentModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'orderId': orderId,
      'amount': amount,
      'status': status,
      'paymentMethod': paymentMethod,
      if (transactionId != null) 'transactionId': transactionId,
      if (metadata != null) 'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  /// Check if payment was successful
  bool get isSuccessful => status == 'completed' || status == 'succeeded';
  
  /// Check if payment is still pending
  bool get isPending => status == 'pending' || status == 'processing';
  
  /// Check if payment failed
  bool get isFailed => status == 'failed' || status == 'declined';
  
  /// Helper method to convert string to CardType
  static CardType getCardTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'visa':
        return CardType.visa;
      case 'mastercard':
        return CardType.mastercard;
      case 'amex':
      case 'american express':
        return CardType.amex;
      case 'discover':
        return CardType.discover;
      default:
        return CardType.unknown;
    }
  }
  
  /// Helper method to convert CardType to string
  static String getStringFromCardType(CardType type) {
    switch (type) {
      case CardType.visa:
        return 'visa';
      case CardType.mastercard:
        return 'mastercard';
      case CardType.amex:
        return 'amex';
      case CardType.discover:
        return 'discover';
      case CardType.unknown:
        return 'unknown';
    }
  }
  
  @override
  String toString() {
    return 'Payment #${id ?? 'New'} - $status - \$${amount.toStringAsFixed(2)}';
  }
}

/// Saved card model for use in UI
class SavedCard extends Equatable {
  final String id;
  final String lastFourDigits;
  final String expiryDate;
  final String cardholderName;
  final CardType cardType;
  
  const SavedCard({
    required this.id,
    required this.lastFourDigits,
    required this.expiryDate,
    required this.cardholderName,
    this.cardType = CardType.unknown,
  });
  
  factory SavedCard.fromMap(Map<String, dynamic> map) {
    return SavedCard(
      id: map['id'] as String,
      lastFourDigits: map['lastFourDigits'] as String,
      expiryDate: map['expiryDate'] as String,
      cardholderName: map['cardholderName'] as String,
      cardType: map['cardType'] != null 
          ? PaymentModel.getCardTypeFromString(map['cardType'] as String)
          : CardType.unknown,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastFourDigits': lastFourDigits,
      'expiryDate': expiryDate,
      'cardholderName': cardholderName,
      'cardType': PaymentModel.getStringFromCardType(cardType),
    };
  }
  
  @override
  List<Object> get props => [id, lastFourDigits, expiryDate, cardholderName, cardType];
}

/// Payment result model
class PaymentResult extends Equatable {
  final String transactionId;
  final bool success;
  final DateTime transactionDate;
  final String? errorMessage;
  final String last4Digits;
  
  const PaymentResult({
    required this.transactionId,
    required this.success,
    required this.transactionDate,
    this.errorMessage,
    this.last4Digits = '',
  });
  
  factory PaymentResult.fromMap(Map<String, dynamic> map) {
    return PaymentResult(
      transactionId: map['transactionId'] as String,
      success: map['success'] as bool,
      transactionDate: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      last4Digits: map['last4Digits'] as String? ?? '',
      errorMessage: map['errorMessage'] as String?,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'success': success,
      'timestamp': transactionDate.millisecondsSinceEpoch,
      'last4Digits': last4Digits,
      'errorMessage': errorMessage,
    };
  }
  
  @override
  List<Object?> get props => [transactionId, success, transactionDate, errorMessage, last4Digits];
}

/// Enum for credit card types
enum CardType {
  visa,
  mastercard,
  amex,
  discover,
  unknown,
}

/// Detect card type from card number
CardType detectCardType(String cardNumber) {
  // Remove any non-digits
  final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
  
  // Check for card type based on prefix
  if (cleanNumber.startsWith('4')) {
    return CardType.visa;
  } else if (cleanNumber.startsWith('5') && 
      int.parse(cleanNumber.substring(1, 2)) >= 1 && 
      int.parse(cleanNumber.substring(1, 2)) <= 5) {
    return CardType.mastercard;
  } else if (cleanNumber.startsWith('34') || cleanNumber.startsWith('37')) {
    return CardType.amex;
  } else if (cleanNumber.startsWith('6')) {
    return CardType.discover;
  }
  
  return CardType.unknown;
} 