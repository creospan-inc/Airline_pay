import 'package:flutter/services.dart';
import 'package:skycomfort/data/models/payment_model.dart';

/// A service that interfaces with native code to process payments
class PaymentService {
  static const MethodChannel _channel = MethodChannel('com.skycomfort.payment');
  
  /// Process a payment with the provided card details
  Future<PaymentResult> processPayment({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
    required double amount,
    required bool saveCard,
  }) async {
    try {
      final Map<String, dynamic> arguments = {
        'cardNumber': cardNumber,
        'expiryDate': expiryDate,
        'cvv': cvv,
        'cardholderName': cardholderName,
        'amount': amount,
        'saveCard': saveCard,
      };
      
      final Map<dynamic, dynamic> result = 
          await _channel.invokeMethod('processPayment', arguments);
      
      return PaymentResult.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw PaymentException(
        code: e.code,
        message: e.message ?? 'Unknown error occurred',
        details: e.details,
      );
    }
  }
  
  /// Process a payment with a saved card
  Future<PaymentResult> processPaymentWithSavedCard({
    required String cardId,
    required double amount,
  }) async {
    try {
      final Map<String, dynamic> arguments = {
        'cardId': cardId,
        'amount': amount,
      };
      
      final Map<dynamic, dynamic> result = 
          await _channel.invokeMethod('processPaymentWithSavedCard', arguments);
      
      return PaymentResult.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw PaymentException(
        code: e.code,
        message: e.message ?? 'Unknown error occurred',
        details: e.details,
      );
    }
  }
  
  /// Get all saved cards
  Future<List<SavedCard>> getSavedCards() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getSavedCards');
      
      return result
        .cast<Map<dynamic, dynamic>>()
        .map((map) => SavedCard.fromMap(Map<String, dynamic>.from(map)))
        .toList();
    } on PlatformException catch (e) {
      throw PaymentException(
        code: e.code,
        message: e.message ?? 'Unknown error occurred',
        details: e.details,
      );
    }
  }
  
  /// Delete a saved card
  Future<bool> deleteSavedCard(String cardId) async {
    try {
      final bool result = await _channel.invokeMethod(
        'deleteSavedCard',
        {'cardId': cardId},
      );
      
      return result;
    } on PlatformException catch (e) {
      throw PaymentException(
        code: e.code,
        message: e.message ?? 'Unknown error occurred',
        details: e.details,
      );
    }
  }
}

/// Exception thrown when a payment operation fails
class PaymentException implements Exception {
  final String code;
  final String message;
  final dynamic details;
  
  PaymentException({
    required this.code,
    required this.message,
    this.details,
  });
  
  @override
  String toString() => 'PaymentException: [$code] $message';
} 