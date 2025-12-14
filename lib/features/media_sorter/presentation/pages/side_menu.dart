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

  /// Recursive helper to build the tree UI
  /// We pass [controller] in to avoid repetitive context lookups during recursion
  Widget _buildNodeTree(BuildContext context, NodeStruct node, SpreadsheetController controller) {
    // 1. Check strict visibility rule
    if (node.hideIfEmpty && node.children.isEmpty) {
      return const SizedBox.shrink();
    }

    // 2. Leaf Node (No children) -> Simple List Tile
    // Note: If you want "Infinite Progression" where a node LOOKS like a leaf
    // but loads data on click, you might need to change this logic to check 
    // a flag like `node.hasChildren` instead of `node.children.isEmpty`.
    if (node.children.isEmpty) {
      return ListTile(
        title: Text(node.message ?? '', style: const TextStyle(fontSize: 13)),
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.only(left: 16.0),
        onTap: () {
          // Optional: You might want to trigger loading on leaves too?
        },
      );
    }

    // 3. Branch Node (Has children) -> Expansion Tile
    return ExpansionTile(
      // CRITICAL: Uniquely identify this widget based on the Node instance.
      // This ensures that when the tree rebuilds, Flutter knows this is the same node.
      key: ObjectKey(node),
      
      title: Text(
        node.message ?? '',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      dense: true,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 12.0),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      
      // BIND STATE: Map depth 0 to expanded, others to collapsed
      initiallyExpanded: node.depth == 0,
      
      // TRIGGER CONTROLLER: When user clicks the arrow
      onExpansionChanged: (bool isExpanded) {
        // We use the controller passed from the parent build method
        // to avoid looking up context inside a callback asynchronously
        controller.toggleNodeExpansion(node, isExpanded);
      },
      
      children: node.children
          .map((child) => _buildNodeTree(context, child, controller))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch controller for changes (rebuilds this widget when notifyListeners is called)
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

          // --- Autocomplete Input Field (Kept as is) ---
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

          // --- Dynamic Tree View Section ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Pass 'context' and 'controller' into the builder
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