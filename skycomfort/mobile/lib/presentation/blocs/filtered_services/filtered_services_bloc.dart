import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skycomfort/data/models/service_model.dart';
import 'package:skycomfort/data/repositories/service_repository.dart';
import 'package:skycomfort/presentation/blocs/services/services_bloc.dart';

part 'filtered_services_event.dart';
part 'filtered_services_state.dart';

class FilteredServicesBloc extends Bloc<FilteredServicesEvent, FilteredServicesState> {
  final ServiceRepository serviceRepository;
  final ServicesBloc servicesBloc;
  late StreamSubscription servicesSubscription;
  
  FilteredServicesBloc({
    required this.serviceRepository,
    required this.servicesBloc,
  }) : super(const FilteredServicesState(
         filteredServices: [],
         selectedType: ServiceType.meal
       )) {
    
    on<FilterServices>(_onFilterServices);
    on<UpdateFilteredServices>(_onUpdateFilteredServices);
    
    // Listen to the services bloc state changes
    servicesSubscription = servicesBloc.stream.listen((servicesState) {
      if (servicesState is ServicesLoaded) {
        add(UpdateFilteredServices(
          allServices: servicesState.services, 
          selectedType: state.selectedType
        ));
      }
    });
  }
  
  Future<void> _onFilterServices(
    FilterServices event,
    Emitter<FilteredServicesState> emit,
  ) async {
    final currentState = servicesBloc.state;
    
    if (currentState is ServicesLoaded) {
      add(UpdateFilteredServices(
        allServices: currentState.services,
        selectedType: event.serviceType
      ));
    }
  }
  
  void _onUpdateFilteredServices(
    UpdateFilteredServices event,
    Emitter<FilteredServicesState> emit,
  ) {
    final filteredServices = event.allServices
        .where((service) => service.type == event.selectedType)
        .toList();
    
    emit(FilteredServicesState(
      filteredServices: filteredServices,
      selectedType: event.selectedType
    ));
  }
  
  @override
  Future<void> close() {
    servicesSubscription.cancel();
    return super.close();
  }
} 