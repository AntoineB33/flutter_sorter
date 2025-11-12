import 'package:flutter/material.dart';
import '../data/spreadsheet_data.dart';
import '../widgets/spreadsheet_view.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../data/js_node.dart';
import '../widgets/js_tree_view.dart';


class SpreadsheetPage extends StatefulWidget {
  const SpreadsheetPage({super.key});

  @override
  State<SpreadsheetPage> createState() => _SpreadsheetPageState();
}

class _SpreadsheetPageState extends State<SpreadsheetPage> {
  SpreadsheetData? _data;
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  late JavascriptRuntime _jsRuntime;
  String? _jsCode;
  String _jsOutput = '';
  JsNode? _jsTree;

  @override
  void initState() {
    super.initState();
    _loadSpreadsheet();
    _initJs();
  }

  Future<void> _initJs() async {
    _jsRuntime = getJavascriptRuntime();
    _jsCode = await rootBundle.loadString('assets/js/cell_processor.js');
    _jsRuntime.evaluate(_jsCode!);
  }

  void _processSelectedValue(String value) {
    if (_jsCode == null) return;

    try {
      final result = _jsRuntime.evaluate('processCell("$value");');
      final decoded = jsonDecode(result.stringResult);
      setState(() {
        _jsTree = JsNode.fromJson(decoded);
        _jsOutput = _jsTree!.text;
      });
    } catch (e) {
      setState(() {
        _jsOutput = 'Error: $e';
        _jsTree = null;
      });
    }
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
                      onChanged: () async {
                        await _saveSpreadsheet();
                      },
                      onCellSelected: (value) {
                        _processSelectedValue(value);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_jsTree != null)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              padding: const EdgeInsets.all(8),
              height: 200,
              child: SingleChildScrollView(
                child: JsTreeView(node: _jsTree!),
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
            'Rows: ${_data!.rowCount} | Columns: ${_data!.colCount}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
