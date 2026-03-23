class LayoutData {
  final List<double> rowsBottomPos;
  final List<double> colRightPos;
  final List<bool> rowsManuallyAdjustedHeight;
  final List<bool> colsManuallyAdjustedWidth;
  double colHeaderHeight;
  double rowHeaderWidth;
  double scrollOffsetX;
  double scrollOffsetY;

  LayoutData({
    required this.rowsBottomPos,
    required this.colRightPos,
    required this.rowsManuallyAdjustedHeight,
    required this.colsManuallyAdjustedWidth,
    required this.colHeaderHeight,
    required this.rowHeaderWidth,
    required this.scrollOffsetX,
    required this.scrollOffsetY,
  });
}