class LayoutData {
  List<double> rowsBottomPos;
  List<double> colRightPos;
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

  factory LayoutData.empty() {
    return LayoutData(
      rowsBottomPos: [],
      colRightPos: [],
      rowsManuallyAdjustedHeight: [],
      colsManuallyAdjustedWidth: [],
      colHeaderHeight: 0,
      rowHeaderWidth: 0,
      scrollOffsetX: 0,
      scrollOffsetY: 0,
    );
  }
}