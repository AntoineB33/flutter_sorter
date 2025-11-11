import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/spreadsheet_data.dart';
import '../widgets/spreadsheet_view.dart';

class SpreadsheetPage extends StatefulWidget {
  const SpreadsheetPage({super.key});

  @override
  State<SpreadsheetPage> createState() => _SpreadsheetPageState();
}

class _SpreadsheetPageState extends State<SpreadsheetPage> {
  SpreadsheetData? _data;
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSpreadsheet();
  }

  Future<void> _loadSpreadsheet() async {
    final loaded = await SpreadsheetData.load();
    setState(() {
      _data = loaded ?? SpreadsheetData(initialRows: 20, initialCols: 10);
    });
  }
  
  Future<void> _saveSpreadsheet() async {
    await _data!.save();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Spreadsheet'),
        actions: [
          IconButton(
            tooltip: 'Clear all cells',
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _data!.clearAll();
              });
              _saveSpreadsheet();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToolbar(context),
          const Divider(height: 1),
          Expanded(
            child: Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: Scrollbar(
                  controller: _verticalController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _verticalController,
                    scrollDirection: Axis.vertical,
                    child: SpreadsheetView(
                      data: _data!,
                      onCellTap: _editCell,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Row'),
            onPressed: () {
              setState(() {
                _data!.addRow();
              });
              _saveSpreadsheet();
            },
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Column'),
            onPressed: () {
              setState(() {
                _data!.addColumn();
              });
              _saveSpreadsheet();
            },
          ),
          const Spacer(),
          Text(
            'Rows: ${_data!.rowCount}  |  Columns: ${_data!.colCount}',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }

  Future<void> _editCell(int row, int col) async {
    final currentValue = _data!.getCell(row, col);
    final controller = TextEditingController(text: currentValue);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${_data!.columnLabel(col)}$row'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Cell value',
            ),
            onSubmitted: (value) {
              Navigator.of(context).pop(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _data!.setCell(row, col, result);
      });
      _saveSpreadsheet();
    }
  }
}
