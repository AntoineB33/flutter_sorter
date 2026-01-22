import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';

class GetDefaultSizes {
  double getDefaultRowHeight() {
    return PageConstants.defaultFontHeight + 2 * PageConstants.verticalPadding;
  }

  double getDefaultCellWidth() {
    return PageConstants.defaultCellWidth + 2 * PageConstants.horizontalPadding;
  }
}