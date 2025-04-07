part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  
  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  final String? message;
  
  const PaymentLoading({this.message});
  
  @override
  List<Object> get props => message != null ? [message!] : [];
}

class SavedCardsLoaded extends PaymentState {
  final List<SavedCard> savedCards;
  final CartModel cart;
  
  const SavedCardsLoaded({
    required this.savedCards,
    required this.cart,
  });
  
  @override
  List<Object> get props => [savedCards, cart];
}

class PaymentValidationSuccess extends PaymentState {
  const PaymentValidationSuccess();
}

class PaymentValidationFailure extends PaymentState {
  final String message;
  
  const PaymentValidationFailure({required this.message});
  
  @override
  List<Object> get props => [message];
}

class PaymentSuccess extends PaymentState {
  final PaymentResult paymentResult;
  
  const PaymentSuccess({required this.paymentResult});
  
  @override
  List<Object> get props => [paymentResult];
}

class PaymentFailure extends PaymentState {
  final String error;
  
  const PaymentFailure({required this.error});
  
  @override
  List<Object> get props => [error];
} 