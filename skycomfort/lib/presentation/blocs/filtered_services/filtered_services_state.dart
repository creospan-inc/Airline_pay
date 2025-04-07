part of 'filtered_services_bloc.dart';

class FilteredServicesState extends Equatable {
  final List<ServiceModel> filteredServices;
  final ServiceType selectedType;

  const FilteredServicesState({
    required this.filteredServices,
    required this.selectedType,
  });

  @override
  List<Object> get props => [filteredServices, selectedType];

  FilteredServicesState copyWith({
    List<ServiceModel>? filteredServices,
    ServiceType? selectedType,
  }) {
    return FilteredServicesState(
      filteredServices: filteredServices ?? this.filteredServices,
      selectedType: selectedType ?? this.selectedType,
    );
  }
} 