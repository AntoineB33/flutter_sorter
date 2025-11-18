import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/spreadsheet_state.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final info = context.watch<SpreadsheetState>().selectedCellInfo;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Text(
        info,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
