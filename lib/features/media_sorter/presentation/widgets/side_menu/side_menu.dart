import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trying_flutter/features/media_sorter/application/coordinators/spreadsheet_coordinator.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/workbook_controller.dart';
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
    final SpreadsheetCoordinator coordinator = context
        .watch<SpreadsheetCoordinator>();

    final WorkbookController workbookController = context
        .watch<WorkbookController>();
    final SheetDataController sheetDataController = context
        .watch<SheetDataController>();
    final SortController sortController = context.watch<SortController>();
    final TreeController treeController = context.watch<TreeController>();

    _textEditingController.text = workbookController.currentSheetName;

    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Autocomplete Input Field ---
          _buildSheetAutocomplete(
            workbookController,
            sheetDataController,
            coordinator,
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              ElevatedButton(
                onPressed: sortController.isReorderBetterButtonLocked()
                    ? null
                    : coordinator.reorderBetterButton,
                child: const Text("Find better sort"),
              ),
              const SizedBox(width: 16),
              Text(
                sortController.isSortedWithValidSort()
                    ? "Sorted"
                    : "Not Sorted",
              ),
            ],
          ),
          
          const SizedBox(height: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Compresses the column to fit its children
            children: [
              // --- Toggle 1 ---
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: 0.7, // Keeps the switch small
                    child: Switch(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Removes extra padding
                      value: sortController.isFindingBestSort(),
                      onChanged: coordinator.findBestSortToggle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Find best sort',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),

              // --- Toggle 2 ---
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: sortController.isCurrentBestSortAlwaysApplied(),
                      onChanged: sortController.isAlwaysApplySortToggleLocked()
                          ? null
                          : coordinator.alwaysApplySortToggle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Apply best sort automatically',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          
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
                              node: treeController.errorRoot,
                              controller: workbookController,
                              treeController: treeController,
                            ),
                            AnalysisTreeNode(
                              node: treeController.warningRoot,
                              controller: workbookController,
                              treeController: treeController,
                            ),
                            AnalysisTreeNode(
                              node: treeController.mentionsRoot,
                              controller: workbookController,
                              treeController: treeController,
                            ),
                            AnalysisTreeNode(
                              node: treeController.searchRoot,
                              controller: workbookController,
                              treeController: treeController,
                            ),
                            AnalysisTreeNode(
                              node: treeController.categoriesRoot,
                              controller: workbookController,
                              treeController: treeController,
                            ),
                            AnalysisTreeNode(
                              node: treeController.distPairsRoot,
                              controller: workbookController,
                              treeController: treeController,
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
    WorkbookController workbookController,
    SheetDataController sheetDataController,
    SpreadsheetCoordinator coordinator,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<CoreSheetContent>(
          displayStringForOption: (CoreSheetContent option) => option.title,
          optionsBuilder: (TextEditingValue textEditingValue) {
            final query = textEditingValue.text.toLowerCase();
            final allSheets = workbookController.getRecentSheetIds();
            if (query.isEmpty) {
              final sorted = List<CoreSheetContent>.from(allSheets);
              sorted.sort(
                (a, b) =>
                    a.title.toLowerCase().compareTo(b.title.toLowerCase()),
              );
              return sorted;
            }
            final matches = <CoreSheetContent>[];
            final others = <CoreSheetContent>[];
            for (var sheetId in allSheets) {
              CoreSheetContent sheet = sheetDataController.getSheet(sheetId);
              if (sheet.title.toLowerCase().contains(query)) {
                matches.add(sheet);
              } else {
                others.add(sheet);
              }
            }
            others.sort(
              (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
            );
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
                      final CoreSheetContent option = options.elementAt(index);
                      final query = _textEditingController.text.toLowerCase();
                      final isMatch = option.title.toLowerCase().contains(
                        query,
                      );
                      bool showDivider = false;
                      if (index > 0 && !isMatch) {
                        final prevOption = options.elementAt(index - 1);
                        final prevWasMatch = prevOption.title
                            .toLowerCase()
                            .contains(query);
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
                            title: Text(option.title),
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
          onSelected: (CoreSheetContent selection) {
            coordinator.loadSheet(selection.id);
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
                    coordinator.createSheetByName(value.trim());
                  },
                );
              },
        );
      },
    );
  }
}
