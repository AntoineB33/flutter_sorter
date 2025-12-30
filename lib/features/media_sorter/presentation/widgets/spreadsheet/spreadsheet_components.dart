import 'package:flutter/material.dart';

class SpreadsheetSelectAllCorner extends StatelessWidget {
  final VoidCallback onTap;
  const SpreadsheetSelectAllCorner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: const Icon(Icons.select_all, size: 16),
      ),
    );
  }
}

class SpreadsheetColumnHeader extends StatelessWidget {
  final String label;
  final int colIndex;
  final Function(TapDownDetails) onContextMenu;

  const SpreadsheetColumnHeader({
    super.key,
    required this.label,
    required this.colIndex,
    required this.onContextMenu,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: onContextMenu,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          border: Border(
            right: BorderSide(color: Colors.grey.shade400),
            bottom: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class SpreadsheetRowHeader extends StatelessWidget {
  final int rowIndex;
  const SpreadsheetRowHeader({super.key, required this.rowIndex});

  @override
  Widget build(BuildContext context) {
    final String label = (rowIndex == 0) ? "Headers" : "$rowIndex";

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        border: Border(
          right: BorderSide(color: Colors.grey.shade400),
          bottom: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: rowIndex == 0 ? FontWeight.bold : FontWeight.normal,
          fontSize: rowIndex == 0 ? 12 : 14,
        ),
      ),
    );
  }
}

class SpreadsheetDataCell extends StatelessWidget {
  final int row;
  final int col;
  final String content;
  final bool isSelected;
  final VoidCallback onTap;

  const SpreadsheetDataCell({
    super.key,
    required this.row,
    required this.col,
    required this.content,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.white,
          border: Border(
            right: BorderSide(color: Colors.grey.shade200),
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Text(content),
      ),
    );
  }
}