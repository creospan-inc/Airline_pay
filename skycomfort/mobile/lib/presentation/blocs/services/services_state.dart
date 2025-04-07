part of 'services_bloc.dart';

abstract class ServicesState extends Equatable {
  const ServicesState();

  @override
  List<Object> get props => [];
}

class ServicesInitial extends ServicesState {}

class ServicesLoading extends ServicesState {}

class ServicesLoaded extends ServicesState {
  final List<ServiceModel> services;
  final List<ServiceModel> selectedServices;
  final double totalAmount;

  const ServicesLoaded({
    required this.services,
    required this.selectedServices,
    required this.totalAmount,
  });

  @override
  List<Object> get props => [services, selectedServices, totalAmount];

  ServicesLoaded copyWith({
    List<ServiceModel>? services,
    List<ServiceModel>? selectedServices,
    double? totalAmount,
  }) {
    return ServicesLoaded(
      services: services ?? this.services,
      selectedServices: selectedServices ?? this.selectedServices,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

class ServicesError extends ServicesState {
  final String message;

  const ServicesError({required this.message});

  @override
  List<Object> get props => [message];
} 