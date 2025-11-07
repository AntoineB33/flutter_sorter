import 'package:flutter/material.dart';


class DraggableFloatingPanel extends StatefulWidget {
  final VoidCallback onAddRow;
  final VoidCallback onExport;

  const DraggableFloatingPanel({
    super.key,
    required this.onAddRow,
    required this.onExport,
  });

  @override
  State<DraggableFloatingPanel> createState() => _DraggableFloatingPanelState();
}

class _DraggableFloatingPanelState extends State<DraggableFloatingPanel> {
  Offset position = const Offset(20, 80);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: buildPanel(),
        childWhenDragging: const SizedBox.shrink(),
        onDragEnd: (details) {
          setState(() {
            position = details.offset;
          });
        },
        child: buildPanel(),
      ),
    );
  }

  Widget buildPanel() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withValues(alpha: 0.95),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: widget.onAddRow,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Row'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: widget.onExport,
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}