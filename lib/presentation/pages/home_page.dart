import 'package:flutter/material.dart';
import '../widgets/spreadsheet_widget.dart';
import '../widgets/side_menu.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Spreadsheet Example")),
      body: Row(
        children: const [
          SizedBox(
            width: 200,
            child: SideMenu(),
          ),
          SizedBox(width: 2),
          Expanded(
            flex: 3,
            child: SpreadsheetWidget(),
          ),
        ],
      ),
    );
  }
}
