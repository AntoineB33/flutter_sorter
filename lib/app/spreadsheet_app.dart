import 'package:flutter/material.dart';
import '../pages/spreadsheet_page.dart';

class SpreadsheetApp extends StatelessWidget {
  const SpreadsheetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Spreadsheet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const SpreadsheetPage(),
    );
  }
}
