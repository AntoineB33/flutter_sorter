import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../logic/spreadsheet_state.dart';
import '../../data/models/cell.dart';

class SpreadsheetWidget extends StatefulWidget {
  final int rows;
  final int cols;

  const SpreadsheetWidget({super.key, this.rows = 30, this.cols = 10});

  @override
  State<SpreadsheetWidget> createState() => _SpreadsheetWidgetState();
}

class _SpreadsheetWidgetState extends State<SpreadsheetWidget> {
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

        final isPaste = (event.logicalKey == LogicalKeyboardKey.keyV) &&
            (event.logicalKey == LogicalKeyboardKey.keyV) &&
            (event is KeyDownEvent) &&
            (HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isMetaPressed);

        // Detect CTRL/CMD + V
        if ((HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isMetaPressed) &&
            key == 'v') {
          final data = await Clipboard.getData('text/plain');
          if (data?.text != null) {
            context.read<SpreadsheetState>().pasteText(data!.text!);
          }
        }

        // You can add arrow key navigation here later
      },
      child: buildGrid(context, state),
    );
  }

  Widget buildGrid(BuildContext context, SpreadsheetState state) {
    final grid = state.grid;

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
              width: widget.cols * 120,
              height: widget.rows * 50,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.cols,
                  childAspectRatio: 2.2,
                ),
                itemCount: widget.rows * widget.cols,
                itemBuilder: (context, index) {
                  final row = index ~/ widget.cols;
                  final col = index % widget.cols;

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
