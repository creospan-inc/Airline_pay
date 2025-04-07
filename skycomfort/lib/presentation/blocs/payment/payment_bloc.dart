import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skycomfort/data/models/payment_model.dart';
import 'package:skycomfort/data/models/cart_model.dart';
import 'package:skycomfort/data/models/order_model.dart';
import 'package:skycomfort/data/models/service_model.dart';
import 'package:skycomfort/data/repositories/payment_repository.dart';
import 'package:skycomfort/data/repositories/order_repository.dart';
import 'package:skycomfort/data/sources/native/payment_service.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository paymentRepository;
  final OrderRepository orderRepository;
  late CartModel _cart;
  
  PaymentBloc({
    required this.paymentRepository,
    required this.orderRepository,
  }) : super(const PaymentInitial()) {
    on<InitializePayment>(_onInitializePayment);
    on<LoadSavedCards>(_onLoadSavedCards);
    on<ProcessNewCardPayment>(_onProcessNewCardPayment);
    on<ProcessSavedCardPayment>(_onProcessSavedCardPayment);
    on<ValidateCardDetails>(_onValidateCardDetails);
  }
  
  void _onInitializePayment(
    InitializePayment event,
    Emitter<PaymentState> emit,
  ) {
    _cart = event.cart;
    emit(const PaymentInitial());
  }
  
  Future<void> _onLoadSavedCards(
    LoadSavedCards event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading(message: 'Loading saved cards...'));
    
    try {
      final savedCards = await paymentRepository.getSavedCards();
      
      // If no saved cards from native code, use demo card
      if (savedCards.isEmpty) {
        // Add a demo card for UI testing
        final demoCard = paymentRepository.getDemoSavedCard();
        final demoSavedCard = SavedCard(
          id: demoCard.id ?? 'card_123',
          lastFourDigits: demoCard.lastFourDigits,
          expiryDate: demoCard.expiryDate,
          cardholderName: demoCard.cardholderName,
        );
        
        emit(SavedCardsLoaded(
          savedCards: [demoSavedCard],
          cart: _cart,
        ));
      } else {
        emit(SavedCardsLoaded(
          savedCards: savedCards,
          cart: _cart,
        ));
      }
    } catch (e) {
      emit(PaymentFailure(error: 'Failed to load saved cards: ${e.toString()}'));
    }
  }
  
  Future<void> _onProcessNewCardPayment(
    ProcessNewCardPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    
    try {
      // First validate the card
      final isValid = paymentRepository.validateCardDetails(
        cardNumber: event.cardNumber,
        expiryDate: event.expiryDate,
        cvv: event.cvv,
        cardholderName: event.cardholderName,
      );
      
      if (!isValid) {
        emit(const PaymentFailure(error: 'Invalid card details. Please check your information.'));
        return;
      }
      
      // Process the payment
      final result = await paymentRepository.processPayment(
        cardNumber: event.cardNumber,
        expiryDate: event.expiryDate,
        cvv: event.cvv,
        cardholderName: event.cardholderName,
        amount: event.amount,
        saveCard: event.saveCard,
      );
      
      emit(PaymentSuccess(paymentResult: result));
    } catch (e) {
      emit(PaymentFailure(error: e.toString()));
    }
  }
  
  Future<void> _onProcessSavedCardPayment(
    ProcessSavedCardPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    
    try {
      // Process the payment with saved card
      final result = await paymentRepository.processPaymentWithSavedCard(
        cardId: event.cardId,
        amount: event.amount,
      );
      
      emit(PaymentSuccess(paymentResult: result));
    } catch (e) {
      emit(PaymentFailure(error: e.toString()));
    }
  }
  
  void _onValidateCardDetails(
    ValidateCardDetails event,
    Emitter<PaymentState> emit,
  ) {
    final isValid = paymentRepository.validateCardDetails(
      cardNumber: event.cardNumber,
      expiryDate: event.expiryDate,
      cvv: event.cvv,
      cardholderName: event.cardholderName,
    );
    
    if (isValid) {
      emit(const PaymentValidationSuccess());
    } else {
      emit(const PaymentValidationFailure(message: 'Invalid card details. Please check and try again.'));
    }
  }
} 