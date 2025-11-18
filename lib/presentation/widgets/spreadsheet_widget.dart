import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/cell.dart';
import '../../logic/spreadsheet_state.dart';

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

  @override
  Widget build(BuildContext context) {
    final grid = context.watch<SpreadsheetState>().grid;
    return Scrollbar(
      controller: _horizontalController,
      thumbVisibility: true,
      trackVisibility: true,
      notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _horizontalController,
        child: Scrollbar(
          controller: _verticalController,
          thumbVisibility: true,
          trackVisibility: true,
          notificationPredicate: (notif) => notif.metrics.axis == Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            controller: _verticalController,
            child: SizedBox(
              width: widget.cols * 120,  // Adjust cell widths if needed
              height: widget.rows * 50,  // Adjust row heights if needed
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

                  final isSelected =
                      context.watch<SpreadsheetState>().selectedCell?.row == row &&
                      context.watch<SpreadsheetState>().selectedCell?.col == col;

                  return InkWell(
                    onTap: () {
                      context.read<SpreadsheetState>().selectCell(row, col);
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
