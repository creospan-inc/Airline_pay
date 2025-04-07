import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skycomfort/data/models/service_model.dart';
import 'package:skycomfort/data/repositories/service_repository.dart';
import 'package:skycomfort/presentation/blocs/services/services_bloc.dart';
import 'package:skycomfort/presentation/blocs/filtered_services/filtered_services_bloc.dart';
import 'package:skycomfort/presentation/widgets/service_card.dart';
import 'package:skycomfort/presentation/widgets/service_filter.dart';
import 'package:skycomfort/presentation/pages/payment/payment_page.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ServicesBloc>(
          create: (context) => ServicesBloc(
            serviceRepository: context.read<ServiceRepository>(),
          )..add(const LoadServices()),
        ),
        BlocProvider<FilteredServicesBloc>(
          create: (context) => FilteredServicesBloc(
            serviceRepository: context.read<ServiceRepository>(),
            servicesBloc: context.read<ServicesBloc>(),
          ),
        ),
      ],
      child: const ServicesView(),
    );
  }
}

class ServicesView extends StatelessWidget {
  const ServicesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SkyComfort Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ServicesBloc>().add(const LoadServices());
            },
          ),
        ],
      ),
      body: BlocBuilder<ServicesBloc, ServicesState>(
        builder: (context, servicesState) {
          if (servicesState is ServicesInitial || servicesState is ServicesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (servicesState is ServicesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${servicesState.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ServicesBloc>().add(const LoadServices());
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (servicesState is ServicesLoaded) {
            return _buildLoadedView(context, servicesState);
          }
          
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
  
  Widget _buildLoadedView(BuildContext context, ServicesLoaded servicesState) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<FilteredServicesBloc, FilteredServicesState>(
            builder: (context, filterState) {
              return ServiceFilter(
                selectedType: filterState.selectedType,
                onTypeSelected: (type) {
                  context.read<FilteredServicesBloc>().add(FilterServices(type));
                },
              );
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<FilteredServicesBloc, FilteredServicesState>(
            builder: (context, filterState) {
              if (filterState.filteredServices.isEmpty) {
                return const Center(
                  child: Text('No services available in this category'),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filterState.filteredServices.length,
                itemBuilder: (context, index) {
                  final service = filterState.filteredServices[index];
                  final isSelected = servicesState.selectedServices
                      .any((selected) => selected.id == service.id);
                  
                  return ServiceCard(
                    title: service.title,
                    description: service.description,
                    price: service.price,
                    isSelected: isSelected,
                    onToggle: () {
                      context.read<ServicesBloc>().add(ToggleService(service));
                    },
                  );
                },
              );
            },
          ),
        ),
        _buildCartSummary(context, servicesState),
      ],
    );
  }
  
  Widget _buildCartSummary(BuildContext context, ServicesLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Items: ${state.selectedServices.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Total: \$${state.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.selectedServices.isNotEmpty
                  ? () {
                      context.push('/payment', extra: {
                        'totalAmount': state.totalAmount,
                        'selectedServices': state.selectedServices,
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Proceed to Payment',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          if (state.selectedServices.isNotEmpty) 
            TextButton(
              onPressed: () {
                context.read<ServicesBloc>().add(const ClearSelection());
              },
              child: const Text('Clear Selection'),
            ),
        ],
      ),
    );
  }
}

// Service item model
class ServiceItem {
  final String id;
  final String title;
  final String description;
  final double price;
  final ServiceType type;
  
  ServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.type,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceItem && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

// Service card widget
class ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final double price;
  final bool isSelected;
  final VoidCallback onToggle;
  
  const ServiceCard({
    Key? key,
    required this.title,
    required this.description,
    required this.price,
    required this.isSelected,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Checkbox
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onToggle(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Price
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 