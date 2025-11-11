import 'package:flutter/material.dart';
import '../data/spreadsheet_data.dart';

class SpreadsheetView extends StatelessWidget {
  final SpreadsheetData data;
  final void Function(int row, int col) onCellTap;

  const SpreadsheetView({
    super.key,
    required this.data,
    required this.onCellTap,
  });

  static const double cellWidth = 100;
  static const double cellHeight = 40;
  static const double headerHeight = 44;
  static const double headerWidth = 60;

  @override
  Widget build(BuildContext context) {
    final rows = data.rowCount;
    final cols = data.colCount;

    final tableRows = <TableRow>[];

    // Header row
    tableRows.add(
      TableRow(
        children: [
          _buildTopLeftHeader(context),
          for (int c = 1; c <= cols; c++) _buildColumnHeader(context, c),
        ],
      ),
    );

    // Data rows
    for (int r = 1; r <= rows; r++) {
      tableRows.add(
        TableRow(
          children: [
            _buildRowHeader(context, r),
            for (int c = 1; c <= cols; c++)
              _buildCell(
                context,
                row: r,
                col: c,
                value: data.getCell(r, c),
              ),
          ],
        ),
      );
    }

    return Table(
      defaultColumnWidth: const FixedColumnWidth(cellWidth),
      border: TableBorder.all(
        color: Theme.of(context).dividerColor,
        width: 0.5,
      ),
      children: tableRows,
    );
  }

  Widget _buildTopLeftHeader(BuildContext context) {
    return SizedBox(
      width: headerWidth,
      height: headerHeight,
      child: Container(
        alignment: Alignment.center,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: const Text(
          '#',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildColumnHeader(BuildContext context, int col) {
    return SizedBox(
      width: cellWidth,
      height: headerHeight,
      child: Container(
        alignment: Alignment.center,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Text(
          data.columnLabel(col),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildRowHeader(BuildContext context, int row) {
    return SizedBox(
      width: headerWidth,
      height: cellHeight,
      child: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Text(
          '$row',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCell(
    BuildContext context, {
    required int row,
    required int col,
    required String value,
  }) {
    return SizedBox(
      width: cellWidth,
      height: cellHeight,
      child: InkWell(
        onTap: () => onCellTap(row, col),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
