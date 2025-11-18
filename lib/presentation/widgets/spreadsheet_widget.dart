import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../logic/spreadsheet_state.dart';

class SpreadsheetWidget extends StatefulWidget {

  const SpreadsheetWidget({super.key});

  @override
  State<SpreadsheetWidget> createState() => _SpreadsheetWidgetState();
}

class _SpreadsheetWidgetState extends State<SpreadsheetWidget> {
  static const double cellWidth = 100;
  static const double cellHeight = 40;
  static const double headerHeight = 44;
  static const double headerWidth = 60;
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SpreadsheetState>();

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) async {
        // Only react on key down
        if (event is! KeyDownEvent) return;

        final key = event.logicalKey.keyLabel.toLowerCase();
        final state = context.read<SpreadsheetState>();

        // Detect CTRL/CMD + V
        if ((HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isMetaPressed) &&
            key == 'v') {
          final data = await Clipboard.getData('text/plain');
          if (data?.text != null) {
            state.pasteText(data!.text!);
          }
        }

        // You can add arrow key navigation here later
      },
      child: buildGrid(context, state),
    );
  }

  Widget buildGrid(BuildContext context, SpreadsheetState state) {
    final grid = state.grid;
    final rows = state.rowCount;
    final cols = state.colCount;

    return Scrollbar(
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
            child: SizedBox(
              width: cols * cellWidth,
              height: rows * cellHeight,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  childAspectRatio: cellWidth / cellHeight,
                ),
                itemCount: rows * cols,
                itemBuilder: (context, index) {
                  final row = index ~/ cols;
                  final col = index % cols;

                  final cell = grid[row][col];
                  final isSelected = state.selectedCell?.row == row &&
                      state.selectedCell?.col == col;

                  return InkWell(
                    onTap: () {
                      context.read<SpreadsheetState>().selectCell(row, col);
                      _focusNode.requestFocus(); // keep keyboard focus
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(1),
                      color: isSelected
                          ? Colors.blue.shade300
                          : Colors.grey.shade200,
                      child: Text(cell.value),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
