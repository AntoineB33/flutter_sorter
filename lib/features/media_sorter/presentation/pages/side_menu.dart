// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';

// class SideMenu extends StatefulWidget {
//   const SideMenu({super.key});

//   @override
//   State<SideMenu> createState() => _SideMenuState();
// }

// class _SideMenuState extends State<SideMenu> {
//   final TextEditingController _controller = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // Initialize controller with current name
//     final state = context.read<SpreadsheetState>();
//     _controller.text = state.spreadsheetName;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Watch state for updates
//     final state = context.watch<SpreadsheetState>();
    
//     // Logic to keep cursor at end when typing
//     if (_controller.text != state.spreadsheetName) {
//       _controller.text = state.spreadsheetName;
//       _controller.selection = TextSelection.fromPosition(
//         TextPosition(offset: _controller.text.length),
//       );
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: Colors.grey.shade100,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // --- Spreadsheet name input ---
//           TextField(
//             controller: _controller,
//             decoration: const InputDecoration(
//               labelText: "Spreadsheet name",
//               border: OutlineInputBorder(),
//               isDense: true,
//             ),
//             onSubmitted: (value) async {
//               if (value.trim().isEmpty) return;
//               await context.read<SpreadsheetState>().loadSpreadsheet(value);
//             },
//           ),
//           const SizedBox(height: 20),

//           // --- Tree View Area ---
//           const Text("Structure",
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
//           const Divider(),
          
//           Expanded(
//             child: SingleChildScrollView(
//                     child: TreeNodeWidget(
//                       node: state.mentionsRoot,
//                       state: state,
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // --- Recursive Tree Node Widget ---

// class TreeNodeWidget extends StatefulWidget {
//   final NodeStruct node;
//   final SpreadsheetState state;

//   const TreeNodeWidget({
//     super.key,
//     required this.node,
//     required this.state,
//   });

//   @override
//   State<TreeNodeWidget> createState() => _TreeNodeWidgetState();
// }

// class _TreeNodeWidgetState extends State<TreeNodeWidget> {
//   bool _isExpanded = false;

//   @override
//   void initState() {
//     super.initState();
//     // Default expansion logic based on depth (mimicking JS: node.depth < 2)
//     _isExpanded = widget.node.depth < 2; 
//   }

//   String _getColumnLabel(int index) {
//     // Simple mock A, B, C... 
//     return String.fromCharCode(65 + index); 
//   }

//   String _getRowName(int index) {
//     return "Row $index";
//   }

//   String _buildLabelText() {
//     final node = widget.node;
//     // Helper to access table data safely
//     String getCellValue(int r, int c) {
//       if (r < widget.state.table.length && c < widget.state.table[r].length) {
//         return widget.state.table[r][c].toString();
//       }
//       return "";
//     }

//     String text = "";

//     if (node.message != null) {
//       text = node.message!;
//     } else {
//       // Translated JS Logic
//       if (node.row != null && node.col == null) {
//         text = _getRowName(node.row!);
//       } else if (node.row != null) {
//         text = "${_getColumnLabel(node.col!)}${node.row}: ${getCellValue(node.row!, node.col!)}";
//       } else if (node.col != null) {
//         // Assuming row 0 is header for "column X: value" logic
//         text = "column ${_getColumnLabel(node.col!)}: ${getCellValue(0, node.col!)}";
//       } else if (node.att != null) {
//         text = "attribute column ${_getColumnLabel(node.col!)}: ${node.att}";
//       }
//     }

//     if (node.children.isNotEmpty) {
//       text += " (${node.children.length})";
//     }
    
//     return text;
//   }

//   void _handleLabelClick() {
//     final node = widget.node;
//     if (node.row != null && node.col != null) {
//       // Navigate to cell
//       print("Go to cell: ${node.row}, ${node.col}");
//       // TODO: Implement actual navigation in state
//       // widget.state.selectCell(node.row!, node.col!); 
//     } else {
//       // Toggle visibility
//       setState(() {
//         _isExpanded = !_isExpanded;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final node = widget.node;

//     // "hideIfEmpty" logic
//     if (node.hideIfEmpty && node.children.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             // Arrow (Toggle)
//             InkWell(
//               onTap: () {
//                 setState(() {
//                   _isExpanded = !_isExpanded;
//                 });
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(4.0),
//                 child: Icon(
//                   _isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
//                   size: 20,
//                   color: node.children.isEmpty ? Colors.transparent : Colors.black,
//                 ),
//               ),
//             ),
            
//             // Label
//             Expanded(
//               child: InkWell(
//                 onTap: _handleLabelClick,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 4.0),
//                   child: Text(
//                     _buildLabelText(),
//                     style: const TextStyle(fontSize: 14),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
        
//         // Children (Recursive)
//         if (_isExpanded && node.children.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.only(left: 16.0), // Indentation
//             child: Column(
//               children: node.children
//                   .map((child) => TreeNodeWidget(node: child, state: widget.state))
//                   .toList(),
//             ),
//           ),
//       ],
//     );
//   }
// }