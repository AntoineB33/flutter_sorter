import 'package:flutter/material.dart';

class ResizableOverlayWidget extends StatefulWidget {
  final Widget leftWidget;
  final Widget rightWidget;
  final double initialRightWidth;

  const ResizableOverlayWidget({
    super.key,
    required this.leftWidget,
    required this.rightWidget,
    required this.initialRightWidth,
  });

  @override
  State<ResizableOverlayWidget> createState() => _ResizableOverlayWidgetState();
}

class _ResizableOverlayWidgetState extends State<ResizableOverlayWidget> {
  late double _currentRightWidth;

  @override
  void initState() {
    super.initState();
    _currentRightWidth = widget.initialRightWidth;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        _currentRightWidth = _currentRightWidth.clamp(0.0, maxWidth);
        
        // Calculate the exact X coordinate where the right widget should start
        final leftPosition = maxWidth - _currentRightWidth;
        const double handleWidth = 24.0;

        return Stack(
          children: [
            // Base Layer: Left Widget
            Positioned.fill(
              child: widget.leftWidget,
            ),

            // Overlay Layer: Right Widget
            // By setting both 'left' and 'right: 0', we force the widget 
            // to stretch and fully expand into the available space.
            Positioned(
              left: leftPosition,
              right: 0,
              top: 0,
              bottom: 0,
              child: widget.rightWidget,
            ),

            // Drag Handle Layer
            Positioned(
              left: leftPosition - (handleWidth / 2),
              top: 0,
              bottom: 0,
              width: handleWidth,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      // delta.dx is negative when dragging left. 
                      // Subtracting a negative increases the right width.
                      _currentRightWidth -= details.delta.dx;
                      _currentRightWidth = _currentRightWidth.clamp(0.0, maxWidth);
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}