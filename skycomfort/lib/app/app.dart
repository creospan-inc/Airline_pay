import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite/sqflite.dart';
import 'package:skycomfort/config/themes.dart';
import 'package:skycomfort/data/datasources/database_helper.dart';
import 'package:skycomfort/data/repositories/service_repository.dart';
import 'package:skycomfort/data/repositories/order_repository.dart';
import 'package:skycomfort/data/repositories/payment_repository.dart';
import 'package:skycomfort/presentation/pages/splash/splash_page.dart';
import 'package:skycomfort/presentation/pages/services/services_page.dart';
import 'package:skycomfort/presentation/pages/payment/payment_page.dart';
import 'package:skycomfort/presentation/pages/confirmation/confirmation_page.dart';

class SkyComfortApp extends StatelessWidget {
  final Database database;

  const SkyComfortApp({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final databaseHelper = DatabaseHelper(database: database);
    
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DatabaseHelper>(
          create: (context) => databaseHelper,
        ),
        RepositoryProvider<ServiceRepository>(
          create: (context) => ServiceRepository(databaseHelper: databaseHelper),
        ),
        RepositoryProvider<OrderRepository>(
          create: (context) => OrderRepository(),
        ),
        RepositoryProvider<PaymentRepository>(
          create: (context) => PaymentRepository(),
        ),
      ],
      child: MaterialApp.router(
        title: 'SkyComfort',
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }

  GoRouter get _router => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/services',
        builder: (context, state) => const ServicesPage(),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          if (extras == null) {
            return const ServicesPage(); // Redirect if no data
          }
          
          return PaymentPage(
            totalAmount: extras['totalAmount'] as double,
            selectedServices: extras['selectedServices'],
          );
        },
      ),
      GoRoute(
        path: '/confirmation',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          if (extras == null) {
            return const ServicesPage(); // Redirect if no data
          }
          
          return ConfirmationPage(
            order: extras['order'],
            paymentResult: extras['paymentResult'],
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
} 