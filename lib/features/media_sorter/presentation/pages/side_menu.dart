import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/spreadsheet_controller.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  // Controller for the text input to sync with current sheet name
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

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SpreadsheetController>();

    // Keep text field in sync if the sheet name changes externally
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
          LayoutBuilder(
            builder: (context, constraints) {
              return Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  final query = textEditingValue.text.toLowerCase();
                  final allSheets = controller.availableSheets;

                  // If input is empty, just return everything sorted alphabetically
                  if (query.isEmpty) {
                    final sorted = List<String>.from(allSheets);
                    sorted.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                    return sorted;
                  }

                  // Filter: Split into "Contains" and "Does Not Contain"
                  final matches = <String>[];
                  final others = <String>[];

                  for (var sheet in allSheets) {
                    if (sheet.toLowerCase().contains(query)) {
                      matches.add(sheet);
                    } else {
                      others.add(sheet);
                    }
                  }

                  // Sort the 'others' list alphabetically
                  others.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

                  // Return combined list: Matches first, then Others
                  return [...matches, ...others];
                },

                // 2. Visuals: Custom Dropdown with Divider
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      // Use the width from LayoutBuilder constraints
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final String option = options.elementAt(index);
                            
                            // Re-check logic to see if we need a divider
                            final query = _textEditingController.text.toLowerCase();
                            final isMatch = option.toLowerCase().contains(query);
                            
                            // Check if this is the first item of the "Others" list
                            // (Current is NOT a match, but Previous WAS a match)
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
                
                // 2. On Selection (Clicking list item)
                onSelected: (String selection) {
                  controller.loadSheetByName(selection);
                },

                // 3. The Input Field Builder
                fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                  // Sync our local controller with the Autocomplete's controller
                  // This ensures we can update the text if the model changes
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
          
        ],
      ),
    );
  }
}