import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/spreadsheet_controller.dart';
// Import your entity classes so we can type check or use them
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  /// Recursive helper to build the tree UI
  Widget _buildNodeTree(NodeStruct node) {
    // 1. Check strict visibility rule
    if (node.hideIfEmpty && node.children.isEmpty) {
      return const SizedBox.shrink();
    }

    // 2. Leaf Node (No children) -> Simple List Tile
    if (node.children.isEmpty) {
      return ListTile(
        title: Text(node.message ?? '', style: const TextStyle(fontSize: 13)),
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.only(left: 16.0), // Indent leaves slightly
      );
    }

    // 3. Branch Node (Has children) -> Expansion Tile
    return ExpansionTile(
      title: Text(node.message!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      dense: true,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 12.0), // Indent children
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: node.children.map((child) => _buildNodeTree(child)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch controller for changes
    final controller = context.watch<SpreadsheetController>();

    // Sync text field logic...
    if (_textEditingController.text != controller.sheetName && !controller.isLoading) {
      _textEditingController.text = controller.sheetName;
    }

    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sheet Manager",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // --- Autocomplete Input Field (Your existing code) ---
          LayoutBuilder(
            builder: (context, constraints) {
              return Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  final query = textEditingValue.text.toLowerCase();
                  final allSheets = controller.availableSheets;
                  if (query.isEmpty) {
                    final sorted = List<String>.from(allSheets);
                    sorted.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                    return sorted;
                  }
                  final matches = <String>[];
                  final others = <String>[];
                  for (var sheet in allSheets) {
                    if (sheet.toLowerCase().contains(query)) {
                      matches.add(sheet);
                    } else {
                      others.add(sheet);
                    }
                  }
                  others.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                  return [...matches, ...others];
                },
                optionsViewBuilder: (context, onSelected, options) {
                  debugPrint("Building options view with ${options.length} options");
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final String option = options.elementAt(index);
                            final query = _textEditingController.text.toLowerCase();
                            final isMatch = option.toLowerCase().contains(query);
                            bool showDivider = false;
                            if (index > 0 && !isMatch) {
                              final prevOption = options.elementAt(index - 1);
                              final prevWasMatch = prevOption.toLowerCase().contains(query);
                              if (prevWasMatch) showDivider = true;
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showDivider) ...[
                                  const Divider(height: 1, thickness: 1),
                                  Container(
                                    width: double.infinity,
                                    color: Colors.grey[200],
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    child: const Text(
                                      "Other Sheets",
                                      style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                                ListTile(
                                  title: Text(option),
                                  onTap: () => onSelected(option),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                onSelected: (String selection) {
                  controller.loadSheetByName(selection);
                },
                fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                  if (textController.text != _textEditingController.text) {
                    textController.text = _textEditingController.text;
                  }
                  return TextField(
                    controller: textController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Select or Create Sheet',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.table_chart),
                    ),
                    onSubmitted: (String value) {
                      controller.loadSheetByName(value.trim());
                      onFieldSubmitted();
                    },
                  );
                },
              );
            },
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          
          const Text(
            "Analysis Logs",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          
          // --- Dynamic Tree View Section ---
          // Use Expanded so the trees can scroll within the remaining space
          Expanded(
            child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Explicitly render the specific roots from AnalysisResult
                        _buildNodeTree(controller.errorRoot),
                        _buildNodeTree(controller.warningRoot),
                        _buildNodeTree(controller.mentionsRoot),
                        _buildNodeTree(controller.searchRoot),
                        _buildNodeTree(controller.categoriesRoot),
                        _buildNodeTree(controller.distPairsRoot),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}