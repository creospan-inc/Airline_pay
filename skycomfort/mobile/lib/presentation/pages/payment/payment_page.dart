import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skycomfort/data/models/service_model.dart';
import 'package:skycomfort/data/models/order_model.dart';
import 'package:skycomfort/data/models/order_item_model.dart';
import 'package:skycomfort/data/sources/native/payment_service.dart';
import 'package:skycomfort/data/repositories/payment_repository.dart';
import 'package:skycomfort/data/repositories/order_repository.dart';
import 'package:skycomfort/presentation/blocs/payment/payment_bloc.dart';
import 'package:skycomfort/presentation/pages/confirmation/confirmation_page.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

class PaymentPage extends StatelessWidget {
  final double totalAmount;
  final List<ServiceModel> selectedServices;

  const PaymentPage({
    Key? key, 
    required this.totalAmount,
    required this.selectedServices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaymentBloc(
        paymentRepository: PaymentRepository(),
        orderRepository: OrderRepository(),
      ),
      child: PaymentView(
        totalAmount: totalAmount,
        selectedServices: selectedServices,
      ),
    );
  }
}

class PaymentView extends StatefulWidget {
  final double totalAmount;
  final List<ServiceModel> selectedServices;

  const PaymentView({
    Key? key, 
    required this.totalAmount,
    required this.selectedServices,
  }) : super(key: key);

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardholderNameController = TextEditingController();
  
  bool _saveCard = false;
  bool _usingSavedCard = false;
  
  // Saved card information (for demo purposes)
  final bool _hasSavedCard = false;
  final String _savedCardLastFour = '1234';
  final String _savedCardExpiry = '12/25';
  final String _savedCardHolder = 'John Doe';
  
  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardholderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            // Create order model with the correct parameters
            final order = OrderModel(
              userId: "user123", // This should be fetched from authentication
              flightId: "FL123", // This should be fetched from current flight info
              seatNumber: "A1", // This should be fetched from current seat
              items: widget.selectedServices.map((service) => OrderItemModel(
                serviceId: int.tryParse(service.id) ?? 0,
                quantity: 1,
                price: service.price,
                title: service.title,
                description: service.description,
                type: service.type.toString().split('.').last,
                imageUrl: service.imageUrl,
              )).toList(),
              totalAmount: widget.totalAmount,
              status: 'pending',
              createdAt: DateTime.now(),
            );
            
            // Navigate to confirmation page using GoRouter
            context.go('/confirmation', extra: {
              'order': order,
              'paymentResult': state.paymentResult,
            });
          } else if (state is PaymentFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment error: ${state.error}')),
            );
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing payment...'),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Order summary card
                _buildOrderSummary(),
                
                const SizedBox(height: 24),
                
                // Payment method selector
                _buildPaymentMethodSelector(),
                
                const SizedBox(height: 16),
                
                // Payment form
                if (!_usingSavedCard) _buildPaymentForm(),
                
                const SizedBox(height: 24),
                
                // Pay button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _processPayment,
                    child: Text(
                      'Pay \$${widget.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Cancel button
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // List of selected services
            ...widget.selectedServices.map((service) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service.title,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    '\$${service.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            )),
            
            const Divider(height: 24),
            
            // Total amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${widget.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentMethodSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // New Card option
            RadioListTile<bool>(
              title: const Text('New Card'),
              value: false,
              groupValue: _usingSavedCard,
              onChanged: (value) {
                setState(() {
                  _usingSavedCard = value!;
                });
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            
            // Saved Card option
            RadioListTile<bool>(
              title: const Text('Saved Card (*** 1234)'),
              value: true,
              groupValue: _usingSavedCard,
              onChanged: (value) {
                setState(() {
                  _usingSavedCard = value!;
                });
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Number
          TextFormField(
            controller: _cardNumberController,
            decoration: const InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              prefixIcon: Icon(Icons.credit_card),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter card number';
              }
              if (value.replaceAll(' ', '').length < 16) {
                return 'Please enter a valid card number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Expiry Date and CVV
          Row(
            children: [
              // Expiry Date
              Expanded(
                child: TextFormField(
                  controller: _expiryDateController,
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'MM/YY',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter expiry date';
                    }
                    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                      return 'Use MM/YY format';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // CVV
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter CVV';
                    }
                    if (value.length < 3) {
                      return 'CVV must be 3-4 digits';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Cardholder Name
          TextFormField(
            controller: _cardholderNameController,
            decoration: const InputDecoration(
              labelText: 'Cardholder Name',
              hintText: 'John Doe',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter cardholder name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Save Card checkbox
          CheckboxListTile(
            title: const Text('Save this card for future payments'),
            value: _saveCard,
            onChanged: (value) {
              setState(() {
                _saveCard = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
  
  void _processPayment() {
    if (_usingSavedCard) {
      // Process payment with saved card
      context.read<PaymentBloc>().add(
        ProcessSavedCardPayment(
          cardId: 'saved_card_id', // This would come from your state management
          amount: widget.totalAmount,
        ),
      );
    } else {
      // Validate form
      if (_formKey.currentState!.validate()) {
        // Process payment with new card
        context.read<PaymentBloc>().add(
          ProcessNewCardPayment(
            cardNumber: _cardNumberController.text,
            expiryDate: _expiryDateController.text,
            cvv: _cvvController.text,
            cardholderName: _cardholderNameController.text,
            amount: widget.totalAmount,
            saveCard: _saveCard,
          ),
        );
      }
    }
  }
} 