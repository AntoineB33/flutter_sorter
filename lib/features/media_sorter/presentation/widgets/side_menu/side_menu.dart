import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/grid_history_selection_data_tree_stream_manager.dart';
import 'analysis_tree_node.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  late TextEditingController _textEditingController;
  late ScrollController _verticalController;
  late ScrollController _horizontalController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _verticalController = ScrollController();
    _horizontalController = ScrollController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  void _handleScroll(PointerEvent event) {
    if (event is PointerScrollEvent) {
      final isCtrlPressed =
          HardwareKeyboard.instance.isLogicalKeyPressed(
            LogicalKeyboardKey.controlLeft,
          ) ||
          HardwareKeyboard.instance.isLogicalKeyPressed(
            LogicalKeyboardKey.controlRight,
          );

      if (isCtrlPressed) {
        final double newOffset =
            _horizontalController.offset + event.scrollDelta.dy;
        if (_horizontalController.hasClients) {
          _horizontalController.jumpTo(
            newOffset.clamp(
              0.0,
              _horizontalController.position.maxScrollExtent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final GridHistorySelectionDataTreeStreamManager spreadsheetController =
        Provider.of<GridHistorySelectionDataTreeStreamManager>(context);

    if (_textEditingController.text != spreadsheetController.sheetName) {
      _textEditingController.text = spreadsheetController.sheetName;
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
          _buildSheetAutocomplete(spreadsheetController),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),

          const Text(
            "Analysis Logs",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // --- Dynamic Tree View Section with Bi-directional Scrolling ---
          Expanded(
            child: Listener(
              onPointerSignal: _handleScroll,
              child: Scrollbar(
                controller: _verticalController,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _verticalController,
                  scrollDirection: Axis.vertical,
                  child: Scrollbar(
                    controller: _horizontalController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    notificationPredicate: (notif) => notif.depth == 1,
                    child: SingleChildScrollView(
                      controller: _horizontalController,
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnalysisTreeNode(
                              node: spreadsheetController.errorRoot,
                              gHSDTManager: spreadsheetController,
                            ),
                            AnalysisTreeNode(
                              node: spreadsheetController.warningRoot,
                              gHSDTManager: spreadsheetController,
                            ),
                            AnalysisTreeNode(
                              node: spreadsheetController.mentionsRoot,
                              gHSDTManager: spreadsheetController,
                            ),
                            AnalysisTreeNode(
                              node: spreadsheetController.searchRoot,
                              gHSDTManager: spreadsheetController,
                            ),
                            AnalysisTreeNode(
                              node: spreadsheetController.categoriesRoot,
                              gHSDTManager: spreadsheetController,
                            ),
                            AnalysisTreeNode(
                              node: spreadsheetController.distPairsRoot,
                              gHSDTManager: spreadsheetController,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetAutocomplete(
    GridHistorySelectionDataTreeStreamManager spreadsheetController,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            final query = textEditingValue.text.toLowerCase();
            final allSheets = spreadsheetController.availableSheets;
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
                        final prevWasMatch = prevOption.toLowerCase().contains(
                          query,
                        );
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: const Text(
                                "Other Sheets",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
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
            spreadsheetController.loadSheetByName(selection);
          },
          fieldViewBuilder:
              (context, textController, focusNode, onFieldSubmitted) {
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
                    spreadsheetController.loadSheetByName(value.trim());
                  },
                );
              },
        );
      },
    );
  }
}
