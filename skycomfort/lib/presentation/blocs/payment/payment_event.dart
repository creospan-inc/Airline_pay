part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class InitializePayment extends PaymentEvent {
  final CartModel cart;
  
  const InitializePayment({required this.cart});
  
  @override
  List<Object> get props => [cart];
}

class LoadSavedCards extends PaymentEvent {
  const LoadSavedCards();
}

class ValidateCardDetails extends PaymentEvent {
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardholderName;

  const ValidateCardDetails({
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardholderName,
  });

  @override
  List<Object> get props => [cardNumber, expiryDate, cvv, cardholderName];
}

class ProcessNewCardPayment extends PaymentEvent {
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardholderName;
  final double amount;
  final bool saveCard;

  const ProcessNewCardPayment({
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardholderName,
    required this.amount,
    required this.saveCard,
  });

  @override
  List<Object> get props => [cardNumber, expiryDate, cvv, cardholderName, amount, saveCard];
}

class ProcessSavedCardPayment extends PaymentEvent {
  final String cardId;
  final double amount;

  const ProcessSavedCardPayment({
    required this.cardId,
    required this.amount,
  });

  @override
  List<Object> get props => [cardId, amount];
} 