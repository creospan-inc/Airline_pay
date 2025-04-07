part of 'services_bloc.dart';

abstract class ServicesEvent extends Equatable {
  const ServicesEvent();

  @override
  List<Object> get props => [];
}

class LoadServices extends ServicesEvent {
  const LoadServices();
}

class ToggleService extends ServicesEvent {
  final ServiceModel service;

  const ToggleService(this.service);

  @override
  List<Object> get props => [service];
}

class ClearSelection extends ServicesEvent {
  const ClearSelection();
} 