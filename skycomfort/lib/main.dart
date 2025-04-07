import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skycomfort/app/app.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:skycomfort/data/datasources/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize database
  final databaseHelper = DatabaseHelper.instance;
  final database = await databaseHelper.database as Database;
  
  runApp(SkyComfortApp(database: database));
} 