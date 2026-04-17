import 'package:flutter/material.dart';

class OverlappingSplitView extends StatefulWidget {
  final Widget leftSide;
  final Widget rightSide;
  final double menuWidth;

  const OverlappingSplitView({
    super.key,
    required this.leftSide,
    required this.rightSide,
    this.menuWidth = 250.0, // Fixed width for the menu
  });

  @override
  State<OverlappingSplitView> createState() => _OverlappingSplitViewState();
}

class _OverlappingSplitViewState extends State<OverlappingSplitView> {
  late double _currentOffset;

  @override
  void initState() {
    super.initState();
    // Start fully open
    _currentOffset = widget.menuWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Background Layer: The static menu
        // Since this width never changes, your text will never wrap or overflow.
        SizedBox(
          width: widget.menuWidth,
          height: double.infinity,
          child: widget.leftSide,
        ),

        // 2. Foreground Layer: The sliding spreadsheet
        Positioned(
          left: _currentOffset,
          top: 0,
          bottom: 0,
          right: 0,
          child: Row(
            children: [
              // Drag Handle
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _currentOffset += details.delta.dx;
                    // Get the total width of the screen/parent
                    double maxWidth = MediaQuery.of(context).size.width; 
                    
                    // Clamp between 0 and the full screen width
                    _currentOffset = _currentOffset.clamp(0.0, maxWidth);
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: Container(
                    width: 8.0,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      border: Border(
                        left: BorderSide(color: Colors.grey[400]!),
                        right: BorderSide(color: Colors.grey[400]!),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.drag_indicator, 
                        size: 16, 
                        color: Colors.grey
                      ),
                    ),
                  ),
                ),
              ),

              // Spreadsheet Content
              Expanded(
                child: Container(
                  color: Colors.white, // Ensure it hides the menu underneath
                  child: widget.rightSide,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}