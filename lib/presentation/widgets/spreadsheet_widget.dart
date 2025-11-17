import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/cell.dart';
import '../../logic/spreadsheet_state.dart';

class SpreadsheetWidget extends StatelessWidget {
  final int rows;
  final int cols;

  const SpreadsheetWidget({super.key, this.rows = 10, this.cols = 5});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
      ),
      itemCount: rows * cols,
      itemBuilder: (context, index) {
        final row = index ~/ cols;
        final col = index % cols;

        final cell = Cell(
          row: row,
          col: col,
          value: "R$row C$col",
        );

        final isSelected =
            context.watch<SpreadsheetState>().selectedCell == cell;

        return InkWell(
          onTap: () {
            context.read<SpreadsheetState>().selectCell(cell);
          },
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(1),
            color: isSelected ? Colors.blue.shade300 : Colors.grey.shade200,
            child: Text(cell.value),
          ),
        );
      },
    );
  }
}
