import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';

class SpreadsheetLayoutCalculator {
  // Pure function: takes text and width, returns height.
  // Does NOT depend on the Controller state.
  double calculateRowHeight(String text, double availableWidth) {
    // Sanity check: If column is collapsed or too small, return a default minimum
    if (availableWidth <= 0) return 30.0;

    // 3. Create a TextPainter
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: PageConstants.cellStyle),
      textDirection: TextDirection.ltr, // Or match your app's directionality
      // Use textScaler if available to respect user's font size settings
      textScaler: TextScaler.noScaling,
    );

    // 4. Layout the text to calculate dimensions
    textPainter.layout(minWidth: 0, maxWidth: availableWidth);

    // 5. Return the text height plus the vertical padding
    // We use math.max to ensure the row never shrinks below a standard single line
    // (approx 17px for font size 14) + padding.
    return (textPainter.height + PageConstants.verticalPadding);
  }
}