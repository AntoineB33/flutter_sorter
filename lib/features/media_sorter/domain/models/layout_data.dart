import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';

class LayoutData {
  List<double> rowsBottomPos;
  List<double> colRightPos;
  final List<bool> rowsManuallyAdjusted;
  final List<bool> colsManuallyAdjusted;
  double colHeaderHeight;
  double rowHeaderWidth;
  double scrollOffsetX;
  double scrollOffsetY;

  LayoutData({
    required this.rowsBottomPos,
    required this.colRightPos,
    required this.rowsManuallyAdjusted,
    required this.colsManuallyAdjusted,
    required this.colHeaderHeight,
    required this.rowHeaderWidth,
    required this.scrollOffsetX,
    required this.scrollOffsetY,
  });

  factory LayoutData.empty() {
    return LayoutData(
      rowsBottomPos: [],
      colRightPos: [],
      rowsManuallyAdjusted: [],
      colsManuallyAdjusted: [],
      colHeaderHeight: PageConstants.defaultColHeaderHeight,
      rowHeaderWidth: PageConstants.defaultRowHeaderWidth,
      scrollOffsetX: 0,
      scrollOffsetY: 0,
    );
  }
}