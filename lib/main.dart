import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the saved route before the app interface renders
  final String savedRoute = await StorageService.getLastRoute();

  runApp(MyApp(initialRoute: savedRoute));
}