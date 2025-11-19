import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/spreadsheet_state.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<SpreadsheetState>();
    _controller.text = state.spreadsheetName;   // <--- Add this
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SpreadsheetState>();
    final info = state.selectedCellInfo;

    _controller.text = state.spreadsheetName;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spreadsheet name input
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Spreadsheet name",
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) async {
              if (value.trim().isEmpty) return;
              await context.read<SpreadsheetState>().loadSpreadsheet(value);
            },
          ),
          const SizedBox(height: 20),

          Text(info, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
