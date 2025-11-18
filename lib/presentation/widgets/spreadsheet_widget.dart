import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

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

    return Row(
      children: [
        // --- Row Header Column ---
        Column(
          children: [
            // Empty corner
            Container(
              width: headerWidth,
              height: headerHeight,
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: const Text(""),
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
                    children: List.generate(cols, (col) {
                      return Container(
                        width: cellWidth,
                        height: headerHeight,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 1),
                        color: Colors.grey.shade300,
                        child: Text(state.columnName(col)),
                      );
                    }),
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

                              final cell = grid[row][col];
                              final isSelected =
                                  state.selectedCell?.row == row &&
                                      state.selectedCell?.col == col;

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
                                  child: Text(cell.value),
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
