import 'package:flutter/material.dart';
import 'screens/spreadsheet_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SpreadsheetApp());
}

class SpreadsheetApp extends StatelessWidget {
  const SpreadsheetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Spreadsheet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const SpreadsheetPage(),
    );
  }
}
