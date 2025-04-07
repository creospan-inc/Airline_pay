import 'package:flutter/material.dart';
import 'package:skycomfort/data/models/service_model.dart';

class ServiceFilter extends StatelessWidget {
  final ServiceType selectedType;
  final Function(ServiceType) onTypeSelected;

  const ServiceFilter({
    Key? key,
    required this.selectedType,
    required this.onTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            _buildFilterChip(context, ServiceType.meal, 'Meals'),
            const SizedBox(width: 8),
            _buildFilterChip(context, ServiceType.beverage, 'Beverages'),
            const SizedBox(width: 8),
            _buildFilterChip(context, ServiceType.entertainment, 'Entertainment'),
            const SizedBox(width: 8),
            _buildFilterChip(context, ServiceType.comfort, 'Comfort'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, ServiceType type, String label) {
    final isSelected = selectedType == type;
    
    return FilterChip(
      selected: isSelected,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 1.5,
        ),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onSelected: (_) => onTypeSelected(type),
    );
  }
} 