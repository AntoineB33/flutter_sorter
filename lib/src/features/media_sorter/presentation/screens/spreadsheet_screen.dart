import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For LogicalKeyboardKey
import 'package:provider/provider.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import '../logic/spreadsheet_controller.dart';

import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/foundation.dart'; // Contains 'compute'
import '../../domain/entities/analysis_result.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'dart:convert';
import 'package:trying_flutter/src/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/src/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/src/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/logger.dart';
import 'package:trying_flutter/logic/async_utils.dart';
import 'package:trying_flutter/logic/hungarian_algorithm.dart';
import 'package:trying_flutter/src/features/media_sorter/domain/entities/dyn_and_int.dart';
import 'package:trying_flutter/src/features/media_sorter/domain/entities/instr_struct.dart';
import 'package:trying_flutter/data/repositories/spreadsheet_repository.dart';
import 'package:trying_flutter/data/models/spreadsheet_data.dart';
import 'package:trying_flutter/src/features/media_sorter/domain/constants/spreadsheet_constants.dart';


class SpreadsheetWidget extends StatefulWidget {
  final SpreadsheetController controller;

  const SpreadsheetWidget({super.key, required this.controller});

  @override
  State<SpreadsheetWidget> createState() => _SpreadsheetWidgetState();
}

class _SpreadsheetWidgetState extends State<SpreadsheetWidget> {
  late final SpreadsheetController controller = widget.controller;
  static const double cellWidth = 100;
  static const double cellHeight = 40;
  static const double headerHeight = 44;
  static const double headerWidth = 60;
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late LinkedScrollControllerGroup _verticalGroup;
  late ScrollController _verticalBody;
  late ScrollController _verticalHeader;

  late LinkedScrollControllerGroup _horizontalGroup;
  late ScrollController _horizontalBody;
  late ScrollController _horizontalHeader;

  @override
  void initState() {
    super.initState();

    _verticalGroup = LinkedScrollControllerGroup();
    _verticalBody = _verticalGroup.addAndGet();
    _verticalHeader = _verticalGroup.addAndGet();

    _horizontalGroup = LinkedScrollControllerGroup();
    _horizontalBody = _horizontalGroup.addAndGet();
    _horizontalHeader = _horizontalGroup.addAndGet();

    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) async {
        // Only react on key down
        if (event is! KeyDownEvent) return;

        final key = event.logicalKey.keyLabel.toLowerCase();

        // Detect CTRL/CMD + C
        if ((HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed) &&
            key == 'c') {
          final copied = await controller.copySelectionToClipboard();
          if (copied != null) {
            debugPrint("Copied:\n$copied");
          }
          return;
        }

        // Detect CTRL/CMD + V
        if ((HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isMetaPressed) &&
            key == 'v') {
          final data = await Clipboard.getData('text/plain');
          if (data?.text != null) {
            controller.pasteText(data!.text!);
          }
        }

        // You can add arrow key navigation here later
      },
      child: buildGrid(context, state),
    );
  }

  Future<void> _showTypeMenu(
    BuildContext context,
    SpreadsheetState state,
    Offset position,
    int col,
  ) async {
    final currentType = state.getColumnType(col);
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: ColumnType.values.map((entry) {
        return CheckedPopupMenuItem<String>(
          value: entry.name,
          checked: entry.name == currentType,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: entry.value == Colors.transparent
                      ? Colors.grey.shade300
                      : entry.value,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Colors.black26),
                ),
              ),
              const SizedBox(width: 8),
              Text(entry.name),
            ],
          ),
        );
      }).toList(),
    );

    if (result != null) {
      setState(() {
        state.setColumnType(col, result);
      });
    }
  }

  void _showColumnContextMenu(BuildContext context, SpreadsheetState state, Offset position, int col) async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        const PopupMenuItem(
          value: 'test1',
          child: Text('Test Action 1'),
        ),
        const PopupMenuItem(
          value: 'test2',
          child: Text('Test Action 2'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'change_type',
          child: Text('Change Type ▶'),
        ),
      ],
    );

    if (!context.mounted) return;

    if (result != null) {
      switch (result) {
        case 'test1':
          debugPrint('Test Action 1 clicked on column ${state.columnName(col)}');
          break;
        case 'test2':
          debugPrint('Test Action 2 clicked on column ${state.columnName(col)}');
          break;
        case 'change_type':
          await _showTypeMenu(context, state, position, col);
          break;
      }
    }
  }

  Widget _buildColumnHeader(BuildContext context, SpreadsheetState state, int col) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showColumnContextMenu(context, state, details.globalPosition, col);
      },
      child: Container(
        width: cellWidth,
        height: headerHeight,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 1),
        color: Colors.grey.shade300,
        child: Text(
          state.columnName(col),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildGrid(BuildContext context, SpreadsheetState state) {
    final rows = 30;
    final cols = 10;

    return Row(
      children: [
        // --- Row Header Column ---
        Column(
          children: [
            Container(
              width: headerWidth,
              height: headerHeight,
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  context.read<SpreadsheetState>().selectRange(
                    0, 0,
                    rows - 1,
                    cols - 1,
                  );
                },
                child: const Icon(Icons.select_all, size: 16),
              ),
            ),
            // Row headers
            Expanded(
              child: Scrollbar(
                controller: _verticalHeader,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _verticalHeader,
                  child: Column(
                    children: List.generate(rows, (row) {
                      return Container(
                        width: headerWidth,
                        height: cellHeight,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: 1),
                        color: Colors.grey.shade300,
                        child: Text("${row + 1}"),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),

        // --- Main Scrollable Area ----
        Expanded(
          child: Column(
            children: [
              // Column header row
              Scrollbar(
                controller: _horizontalHeader,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalHeader,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      cols,
                      (col) => _buildColumnHeader(context, state, col),
                    ),
                  ),
                ),
              ),

              // Main grid scrollable in both directions
              Expanded(
                child: Scrollbar(
                  controller: _verticalBody,
                  thumbVisibility: true,
                  child: Scrollbar(
                    controller: _horizontalBody,
                    thumbVisibility: true,
                    notificationPredicate: (notif) => notif.depth == 1,
                    child: SingleChildScrollView(
                      controller: _verticalBody,
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        controller: _horizontalBody,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: cols * cellWidth,
                          height: rows * cellHeight,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              childAspectRatio: cellWidth / cellHeight,
                            ),
                            itemCount: rows * cols,
                            itemBuilder: (context, index) {
                              final row = index ~/ cols;
                              final col = index % cols;

                              final text = row < state.rowCount && col < state.colCount ? state.table[row][col] : '';
                              final isSelected = state.isCellSelected(row, col);

                              return InkWell(
                                onTap: () {
                                  context
                                      .read<SpreadsheetState>()
                                      .selectCell(row, col);
                                  _focusNode.requestFocus();
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.all(1),
                                  color: isSelected
                                      ? Colors.blue.shade300
                                      : Colors.grey.shade200,
                                  child: Text(text),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

