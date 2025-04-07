part of 'filtered_services_bloc.dart';

abstract class FilteredServicesEvent extends Equatable {
  const FilteredServicesEvent();

  @override
  List<Object> get props => [];
}

class FilterServices extends FilteredServicesEvent {
  final ServiceType serviceType;

  const FilterServices(this.serviceType);

  @override
  List<Object> get props => [serviceType];
}

class UpdateFilteredServices extends FilteredServicesEvent {
  final List<ServiceModel> allServices;
  final ServiceType selectedType;

  const UpdateFilteredServices({
    required this.allServices,
    required this.selectedType,
  });

  @override
  List<Object> get props => [allServices, selectedType];
} 