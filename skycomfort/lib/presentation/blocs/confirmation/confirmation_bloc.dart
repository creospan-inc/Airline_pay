import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skycomfort/data/models/order_model.dart';
import 'package:skycomfort/data/models/payment_model.dart';

// Events
abstract class ConfirmationEvent extends Equatable {
  const ConfirmationEvent();
  
  @override
  List<Object?> get props => [];
}

class InitializeConfirmation extends ConfirmationEvent {
  final OrderModel order;
  final PaymentResult paymentResult;
  
  const InitializeConfirmation({
    required this.order,
    required this.paymentResult,
  });
  
  @override
  List<Object?> get props => [order, paymentResult];
}

// States
abstract class ConfirmationState extends Equatable {
  const ConfirmationState();
  
  @override
  List<Object?> get props => [];
}

class ConfirmationInitial extends ConfirmationState {
  const ConfirmationInitial();
}

class ConfirmationLoaded extends ConfirmationState {
  final OrderModel order;
  final PaymentResult paymentResult;
  final int estimatedDeliveryMinutes;
  
  const ConfirmationLoaded({
    required this.order,
    required this.paymentResult,
    this.estimatedDeliveryMinutes = 30,
  });
  
  @override
  List<Object?> get props => [order, paymentResult, estimatedDeliveryMinutes];
}

class ConfirmationError extends ConfirmationState {
  final String message;
  
  const ConfirmationError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class ConfirmationBloc extends Bloc<ConfirmationEvent, ConfirmationState> {
  ConfirmationBloc() : super(const ConfirmationInitial()) {
    on<InitializeConfirmation>(_onInitializeConfirmation);
  }
  
  void _onInitializeConfirmation(
    InitializeConfirmation event,
    Emitter<ConfirmationState> emit,
  ) {
    try {
      emit(ConfirmationLoaded(
        order: event.order,
        paymentResult: event.paymentResult,
      ));
    } catch (e) {
      emit(ConfirmationError('Failed to load confirmation: ${e.toString()}'));
    }
  }
} 