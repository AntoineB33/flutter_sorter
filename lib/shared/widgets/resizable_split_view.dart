import 'package:flutter/material.dart';

class ResizableSplitView extends StatefulWidget {
  final Widget leftSide;
  final Widget rightSide;
  final double initialWidth;
  final double minWidth;
  final double maxWidth;

  const ResizableSplitView({
    super.key,
    required this.leftSide,
    required this.rightSide,
    this.initialWidth = 250.0,
    this.minWidth = 150.0,
    this.maxWidth = 600.0,
  });

  @override
  State<ResizableSplitView> createState() => _ResizableSplitViewState();
}

class _ResizableSplitViewState extends State<ResizableSplitView> {
  late double _width;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _width = widget.initialWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Left Side
        SizedBox(
          width: _width,
          child: widget.leftSide,
        ),

        // 2. Resizer Handle
        MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (_) => setState(() => _isDragging = true),
            onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
            onHorizontalDragUpdate: (details) {
              setState(() {
                _width = (_width + details.delta.dx)
                    .clamp(widget.minWidth, widget.maxWidth);
              });
            },
            child: Container(
              width: 9, 
              color: Colors.transparent, // Hit test area
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isDragging ? 2 : 1, // Thicken on drag
                height: double.infinity,
                // Change color when dragging for visual feedback
                color: _isDragging ? Theme.of(context).primaryColor : Colors.grey.shade400,
              ),
            ),
          ),
        ),

        // 3. Right Side
        Expanded(
          child: widget.rightSide,
        ),
      ],
    );
  }
}