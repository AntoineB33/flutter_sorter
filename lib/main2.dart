import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: PreciseEditableCellApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class PreciseEditableCellApp extends StatelessWidget {
  const PreciseEditableCellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        // Tap outside to close edit mode
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: const SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: PreciseEditableCell(initialText: "Double-click me to edit.\nThe text will not jump, not even a pixel."),
            ),
          ),
        ),
      ),
    );
  }
}

class PreciseEditableCell extends StatefulWidget {
  final String initialText;

  const PreciseEditableCell({super.key, required this.initialText});

  @override
  State<PreciseEditableCell> createState() => _PreciseEditableCellState();
}

class _PreciseEditableCellState extends State<PreciseEditableCell> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  // Constants for styling
  static const double _borderWidth = 2.0;
  static const EdgeInsets _cellPadding = EdgeInsets.all(12.0);
  static const TextStyle _textStyle = TextStyle(
    fontSize: 20,
    color: Colors.black,
    height: 1.3,
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();

    // When focus is lost, turn off edit mode automatically
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        setState(() {
          _isEditing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _enableEditMode() {
    setState(() {
      _isEditing = true;
    });
    // Request focus immediately
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Detect Double Tap on the Container
    return GestureDetector(
      onDoubleTap: _enableEditMode,
      child: Container(
        width: 300,
        padding: _cellPadding,
        decoration: BoxDecoration(
          color: Colors.white,
          // 2. Handle Border: Transparent in view, Blue in edit.
          // Because width is constant (2.0), layout doesn't shift.
          border: Border.all(
            color: _isEditing ? Colors.blue : Colors.transparent,
            width: _borderWidth,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        // 3. The Core Fix:
        // We use AbsorbPointer when NOT editing.
        // This makes the TextField ignore clicks (passing them to GestureDetector),
        // effectively making it behave like a static Text widget.
        child: AbsorbPointer(
          absorbing: !_isEditing,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: _textStyle,
            maxLines: null, // Allow wrapping
            
            // 4. View vs Edit styling
            // When not editing, we set readOnly: true so no keyboard appears,
            // but since we use the SAME widget, the text rendering is identical.
            readOnly: !_isEditing, 
            showCursor: _isEditing,
            mouseCursor: _isEditing ? SystemMouseCursors.text : SystemMouseCursors.basic,
            
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              // Remove focus color tints
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
