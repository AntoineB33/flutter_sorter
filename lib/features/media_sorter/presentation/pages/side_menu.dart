import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/spreadsheet_controller.dart';
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

  /// Custom Recursive Tree Builder
  Widget _buildNodeTree(BuildContext context, NodeStruct node, SpreadsheetController controller) {
    // 1. Check strict visibility rule
    if (node.hideIfEmpty && node.children.isEmpty) {
      return const SizedBox.shrink();
    }

    // Determine state
    final bool isLeaf = node.children.isEmpty;
    // According to your NodeStruct: depth 0 = expanded, >0 = collapsed
    final bool isExpanded = node.depth == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- The Node Row (Icon + Text) ---
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. The Arrow / Spacer
              if (isLeaf)
                 // Spacer for alignment if it's a leaf (same width as IconButton)
                const SizedBox(width: 32, height: 32)
              else
                // The Toggle Button
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    splashRadius: 16,
                    icon: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      color: Colors.grey[700],
                    ),
                    onPressed: () {
                      // Toggle expansion logic
                      controller.toggleNodeExpansion(node, !isExpanded);
                    },
                  ),
                ),

              // 2. The Node Name (Clickable)
              Expanded(
                child: InkWell(
                  // Action when clicking the name specifically
                  onTap: () {
                     controller.onNodeSelected(node); 
                     print("Selected node: ${node.message}");
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                    child: Text(
                      node.message ?? node.instruction ?? '',
                      style: const TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.w400, // Consistent font weight
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // --- The Children (Recursive) ---
        // Only show if expanded and has children
        if (isExpanded && !isLeaf)
          Container(
            // Indentation
            margin: const EdgeInsets.only(left: 15.0), 
            // The "Structure Line" - A vertical border on the left
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey.withOpacity(0.4), // Line color
                  width: 1.0,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0), // Spacing between line and children
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: node.children
                    .map((child) => _buildNodeTree(context, child, controller))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SpreadsheetController>();

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

          // --- Autocomplete Input Field ---
          // TODO: bug
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
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
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
          const SizedBox(height: 10),

          // --- Dynamic Tree View Section ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNodeTree(context, controller.errorRoot, controller),
                  _buildNodeTree(context, controller.warningRoot, controller),
                  _buildNodeTree(context, controller.mentionsRoot, controller),
                  _buildNodeTree(context, controller.searchRoot, controller),
                  _buildNodeTree(context, controller.categoriesRoot, controller),
                  _buildNodeTree(context, controller.distPairsRoot, controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}