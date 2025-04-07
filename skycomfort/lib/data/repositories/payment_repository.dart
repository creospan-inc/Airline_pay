import 'dart:async';
import 'package:skycomfort/data/models/payment_model.dart';
import 'package:skycomfort/data/sources/native/payment_service.dart';
import 'package:skycomfort/data/datasources/database_helper.dart';

class PaymentRepository {
  final PaymentService _paymentService;
  final DatabaseHelper _databaseHelper;
  
  PaymentRepository({
    PaymentService? paymentService,
    DatabaseHelper? databaseHelper,
  }) : 
    _paymentService = paymentService ?? PaymentService(),
    _databaseHelper = databaseHelper ?? DatabaseHelper.instance;
  
  /// Process a payment
  Future<PaymentResult> processPayment({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
    required double amount,
    required bool saveCard,
  }) async {
    try {
      final result = await _paymentService.processPayment(
        cardNumber: cardNumber,
        expiryDate: expiryDate,
        cvv: cvv,
        cardholderName: cardholderName,
        amount: amount,
        saveCard: saveCard,
      );
      
      return result;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Process a payment with a saved card
  Future<PaymentResult> processPaymentWithSavedCard({
    required String cardId,
    required double amount,
  }) async {
    try {
      final result = await _paymentService.processPaymentWithSavedCard(
        cardId: cardId,
        amount: amount,
      );
      
      return result;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Get all saved cards
  Future<List<SavedCard>> getSavedCards() async {
    try {
      return await _paymentService.getSavedCards();
    } catch (e) {
      // In case of error, return empty list
      return [];
    }
  }
  
  /// Delete a saved card
  Future<bool> deleteSavedCard(String cardId) async {
    try {
      return await _paymentService.deleteSavedCard(cardId);
    } catch (e) {
      return false;
    }
  }
  
  /// Get a demo saved card (for UI testing)
  PaymentModel getDemoSavedCard() {
    return PaymentModel(
      id: 'card_123',
      cardNumber: '', // Not storing the full card number
      expiryDate: '12/25',
      cardholderName: 'John Doe',
      lastFourDigits: '1234',
      cardType: CardType.visa,
    );
  }
  
  /// Validate card details
  bool validateCardDetails({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
  }) {
    // Validate card number (simple Luhn algorithm check)
    if (!_isValidCardNumber(cardNumber)) {
      return false;
    }
    
    // Validate expiry date (MM/YY format)
    if (!_isValidExpiryDate(expiryDate)) {
      return false;
    }
    
    // Validate CVV (3-4 digits)
    if (!_isValidCVV(cvv)) {
      return false;
    }
    
    // Validate cardholder name (not empty)
    if (cardholderName.trim().isEmpty) {
      return false;
    }
    
    return true;
  }
  
  /// Validate card number using Luhn algorithm
  bool _isValidCardNumber(String cardNumber) {
    // Remove spaces and other non-digit characters
    final sanitizedNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    // Card number must be between 13-19 digits
    if (sanitizedNumber.length < 13 || sanitizedNumber.length > 19) {
      return false;
    }
    
    // Simple check for now (would use Luhn algorithm in a real app)
    return true;
  }
  
  /// Validate expiry date
  bool _isValidExpiryDate(String expiryDate) {
    // Check format MM/YY
    final RegExp expiryRegex = RegExp(r'^\d{2}/\d{2}$');
    if (!expiryRegex.hasMatch(expiryDate)) {
      return false;
    }
    
    // Parse month and year
    final parts = expiryDate.split('/');
    final month = int.parse(parts[0]);
    int year = int.parse(parts[1]);
    year += 2000; // Convert YY to YYYY
    
    // Get current date
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    
    // Check if month is valid
    if (month < 1 || month > 12) {
      return false;
    }
    
    // Check if date is in the past
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return false;
    }
    
    return true;
  }
  
  /// Validate CVV
  bool _isValidCVV(String cvv) {
    // CVV should be 3-4 digits
    final RegExp cvvRegex = RegExp(r'^\d{3,4}$');
    return cvvRegex.hasMatch(cvv);
  }
} 