import 'package:flutter/material.dart';
// If you adopted the folder structure, update imports to use 'src':
import 'src/features/spreadsheet/presentation/pages/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spreadsheet Example',
      // Move theme data to a separate file later, but this is fine for now
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}