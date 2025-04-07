import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skycomfort/data/models/service_model.dart';
import 'package:skycomfort/data/repositories/service_repository.dart';

part 'services_event.dart';
part 'services_state.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final ServiceRepository serviceRepository;
  
  ServicesBloc({required this.serviceRepository}) : super(ServicesInitial()) {
    on<LoadServices>(_onLoadServices);
    on<ToggleService>(_onToggleService);
    on<ClearSelection>(_onClearSelection);
  }

  Future<void> _onLoadServices(
    LoadServices event,
    Emitter<ServicesState> emit,
  ) async {
    emit(ServicesLoading());
    try {
      final services = await serviceRepository.getServices();
      emit(ServicesLoaded(
        services: services,
        selectedServices: const [],
        totalAmount: 0.0,
      ));
    } catch (e) {
      emit(ServicesError(message: e.toString()));
    }
  }

  void _onToggleService(
    ToggleService event,
    Emitter<ServicesState> emit,
  ) {
    if (state is ServicesLoaded) {
      final currentState = state as ServicesLoaded;
      List<ServiceModel> updatedSelection = List.from(currentState.selectedServices);
      
      // Check if service is already selected
      final isAlreadySelected = updatedSelection.any((service) => service.id == event.service.id);
      
      if (isAlreadySelected) {
        // Remove from selection
        updatedSelection.removeWhere((service) => service.id == event.service.id);
      } else {
        // Add to selection
        updatedSelection.add(event.service);
      }
      
      // Calculate total amount
      final totalAmount = updatedSelection.fold<double>(
        0.0, 
        (total, service) => total + service.price,
      );
      
      emit(ServicesLoaded(
        services: currentState.services,
        selectedServices: updatedSelection,
        totalAmount: totalAmount,
      ));
    }
  }

  void _onClearSelection(
    ClearSelection event,
    Emitter<ServicesState> emit,
  ) {
    if (state is ServicesLoaded) {
      final currentState = state as ServicesLoaded;
      emit(ServicesLoaded(
        services: currentState.services,
        selectedServices: const [],
        totalAmount: 0.0,
      ));
    }
  }
} 