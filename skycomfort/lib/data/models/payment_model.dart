import 'package:equatable/equatable.dart';

/// Model for payment information
class PaymentModel {
  final String? id;
  final String cardNumber;
  final String expiryDate;
  final String cardholderName;
  final String lastFourDigits;
  final String? cvv; // Only used during transaction, not stored
  final CardType cardType;
  
  PaymentModel({
    this.id,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardholderName,
    required this.lastFourDigits,
    this.cvv,
    this.cardType = CardType.unknown,
  });
  
  /// Create a PaymentModel from a map (for database operations)
  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id']?.toString(),
      cardNumber: map['card_number'] as String,
      expiryDate: map['expiry_date'] as String,
      cardholderName: map['cardholder_name'] as String,
      lastFourDigits: map['last_four_digits'] as String,
      cardType: _getCardTypeFromString(map['card_type'] as String? ?? 'unknown'),
    );
  }
  
  /// Convert PaymentModel to a map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'card_number': cardNumber,
      'expiry_date': expiryDate,
      'cardholder_name': cardholderName,
      'last_four_digits': lastFourDigits,
      'card_type': _getStringFromCardType(cardType),
    };
  }
  
  /// Create a masked card representation for display
  String get maskedCardNumber {
    if (lastFourDigits.isEmpty) {
      return '**** **** **** ****';
    }
    return '**** **** **** $lastFourDigits';
  }
  
  /// Create a copy of the model with updated fields
  PaymentModel copyWith({
    String? id,
    String? cardNumber,
    String? expiryDate,
    String? cardholderName,
    String? lastFourDigits,
    String? cvv,
    CardType? cardType,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cardholderName: cardholderName ?? this.cardholderName,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      cvv: cvv ?? this.cvv,
      cardType: cardType ?? this.cardType,
    );
  }
  
  /// Helper method to convert string to CardType
  static CardType _getCardTypeFromString(String type) {
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
  static String _getStringFromCardType(CardType type) {
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
  
  /// Detect card type from card number
  static CardType detectCardType(String cardNumber) {
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
          ? PaymentModel._getCardTypeFromString(map['cardType'] as String)
          : CardType.unknown,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastFourDigits': lastFourDigits,
      'expiryDate': expiryDate,
      'cardholderName': cardholderName,
      'cardType': PaymentModel._getStringFromCardType(cardType),
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