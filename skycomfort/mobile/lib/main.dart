import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skycomfort/app/app.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:skycomfort/data/datasources/database_helper.dart';
import 'package:skycomfort/data/datasources/sync_manager.dart';
import 'package:provider/provider.dart';
import 'package:skycomfort/data/repositories/service_repository.dart';
import 'package:skycomfort/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize app configuration
  AppConfig.initialize(env: Environment.development);
  
  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize database
  final databaseHelper = DatabaseHelper.instance;
  final database = await databaseHelper.database;
  
  // Initialize sync manager
  final syncManager = SyncManager();
  await syncManager.initialize();
  
  // Create repositories
  final serviceRepository = ServiceRepository(databaseHelper: databaseHelper);
  
  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseHelper>.value(value: databaseHelper),
        Provider<SyncManager>.value(value: syncManager),
        Provider<ServiceRepository>.value(value: serviceRepository),
        Provider<AppConfig>.value(value: AppConfig.getInstance()),
      ],
      child: SkyComfortApp(database: database),
    ),
  );
} 