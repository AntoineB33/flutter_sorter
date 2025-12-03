import 'package:flutter/material.dart';
import 'src/features/media_sorter2/presentation/pages/spreadsheet_page.dart';

class SpreadsheetApp extends StatelessWidget {
  const SpreadsheetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Riverpod Spreadsheet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(8),
        ),
      ),
      home: const SpreadsheetPage(),
    );
  }
}