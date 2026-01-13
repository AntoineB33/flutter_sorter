import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';

class SpreadsheetLayoutCalculator {
  // Pure function: takes text and width, returns height.
  // Does NOT depend on the Controller state.
  double calculateRowHeight(String text, double availableWidth) {
    if (availableWidth <= 0) return 30.0;
    
    const double horizontalPadding = PageConstants.horizontalPadding * 2; // Left + Right padding
    const double borderWidth = PageConstants.borderWidth * 2;       // Left + Right border

    // 1. Adjust available width for text wrapping
    final double textLayoutWidth = availableWidth - horizontalPadding - borderWidth;

    if (textLayoutWidth <= 0) return 30.0;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: PageConstants.cellStyle),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
    );

    // 2. Layout using the constricted width
    textPainter.layout(minWidth: 0, maxWidth: textLayoutWidth);

    // 3. Add Vertical Spacing
    const double verticalPaddingTotal = PageConstants.verticalPadding * 2; 
    const double verticalBorderTotal = PageConstants.borderWidth * 2;

    return textPainter.height + verticalPaddingTotal + verticalBorderTotal;
  }
}