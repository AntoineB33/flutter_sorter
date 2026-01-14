import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: EditableCellApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class EditableCellApp extends StatelessWidget {
  const EditableCellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        // Just a simple tap outside to close edit mode for better UX
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: const SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: EditableCell(initialText: "Double-click me to edit"),
            ),
          ),
        ),
      ),
    );
  }
}

class EditableCell extends StatefulWidget {
  final String initialText;

  const EditableCell({super.key, required this.initialText});

  @override
  State<EditableCell> createState() => _EditableCellState();
}

class _EditableCellState extends State<EditableCell> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;
  
  // Define consistent styling constants
  static const double _borderWidth = 2.0;
  static const EdgeInsets _cellPadding = EdgeInsets.all(12.0);
  static const TextStyle _textStyle = TextStyle(
    fontSize: 24,
    color: Colors.black,
    height: 1.2, // Fix line height to prevent subtle vertical shifts
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
    
    // Listen to focus changes to exit edit mode when focus is lost
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
    // Request focus after the frame rebuilds so the TextField exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _enableEditMode,
      child: Container(
        width: 300, // Fixed width for demonstration
        padding: _cellPadding,
        decoration: BoxDecoration(
          color: Colors.white,
          // TRICK: Always have a border. Make it transparent in view mode.
          // This prevents the content from jumping when the border appears.
          border: Border.all(
            color: _isEditing ? Colors.blue : Colors.transparent,
            width: _borderWidth,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _isEditing ? _buildEditField() : _buildViewText(),
      ),
    );
  }

  Widget _buildViewText() {
    return Text(
      _controller.text,
      style: _textStyle,
    );
  }

  Widget _buildEditField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      style: _textStyle,
      // Allow multiline to match Text widget behavior
      maxLines: null, 
      decoration: const InputDecoration(
        // TRICK: Remove all internal padding from the TextField
        // so it aligns perfectly with the Text widget.
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        
        // Ensure no extra margins are added by errors or counters
        errorStyle: TextStyle(height: 0), 
      ),
    );
  }
}