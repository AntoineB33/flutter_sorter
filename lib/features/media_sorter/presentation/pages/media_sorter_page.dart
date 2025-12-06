import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import '../controllers/spreadsheet_controller.dart'; // Ensure correct import path
import '../../domain/entities/column_type.dart';
import '../utils/column_type_extensions.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/spreadsheet_repository_impl.dart';

class MediaSorterPage extends StatelessWidget {
  const MediaSorterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Wrap the Scaffold in ChangeNotifierProvider
    return ChangeNotifierProvider(
      create: (context) => SpreadsheetController(
        getDataUseCase: GetSheetDataUseCase(SpreadsheetRepositoryImpl()),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Media Sorter"),
        ),
        // The SpreadsheetWidget is now a child of the Provider, 
        // so it can find the controller.
        body: const SpreadsheetWidget(),
      ),
    );
  }
}

class SpreadsheetWidget extends StatefulWidget {
  const SpreadsheetWidget({super.key});

  @override
  State<SpreadsheetWidget> createState() => _SpreadsheetWidgetState();
}

class _SpreadsheetWidgetState extends State<SpreadsheetWidget> {
  static const double cellWidth = 100;
  static const double cellHeight = 40;
  static const double headerHeight = 44;
  static const double headerWidth = 60;
  final FocusNode _focusNode = FocusNode();
  
  late LinkedScrollControllerGroup _verticalGroup;
  late ScrollController _verticalBody;
  late ScrollController _verticalHeader;

  late LinkedScrollControllerGroup _horizontalGroup;
  late ScrollController _horizontalBody;
  late ScrollController _horizontalHeader;

  @override
  void initState() {
    super.initState();

    _verticalGroup = LinkedScrollControllerGroup();
    _verticalBody = _verticalGroup.addAndGet();
    _verticalHeader = _verticalGroup.addAndGet();

    _horizontalGroup = LinkedScrollControllerGroup();
    _horizontalBody = _horizontalGroup.addAndGet();
    _horizontalHeader = _horizontalGroup.addAndGet();

    // Optionally load data on init
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<SpreadsheetController>().loadData();
    // });
    
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the Controller instead of SpreadsheetState
    final controller = context.watch<SpreadsheetController>();

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) async {
        if (event is! KeyDownEvent) return;

        final key = event.logicalKey.keyLabel.toLowerCase();
        // Use read to avoid rebuilding on every key press
        final ctrl = context.read<SpreadsheetController>(); 

        // Detect CTRL/CMD + C
        if ((HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed) &&
            key == 'c') {
          final copied = await ctrl.copySelectionToClipboard();
          if (copied != null) {
            debugPrint("Copied:\n$copied");
          }
          return;
        }

        // Detect CTRL/CMD + V
        if ((HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isMetaPressed) &&
            key == 'v') {
          final data = await Clipboard.getData('text/plain');
          if (data?.text != null) {
            ctrl.pasteText(data!.text!);
          }
        }
      },
      child: buildGrid(context, controller),
    );
  }

  Future<void> _showTypeMenu(
    BuildContext context,
    SpreadsheetController controller,
    Offset position,
    int col,
  ) async {
    final currentType = controller.getColumnType(col);
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: ColumnType.values.map((entry) {
        return CheckedPopupMenuItem<String>(
          value: entry.name,
          checked: entry.name == currentType,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: ColumnTypeX(entry).color == Colors.transparent
                      ? Colors.grey.shade300
                      : ColumnTypeX(entry).color,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Colors.black26),
                ),
              ),
              const SizedBox(width: 8),
              Text(entry.name),
            ],
          ),
        );
      }).toList(),
    );

    if (result != null) {
      controller.setColumnType(col, result);
    }
  }

  void _showColumnContextMenu(
      BuildContext context, SpreadsheetController controller, Offset position, int col) async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        const PopupMenuItem(
          value: 'test1',
          child: Text('Test Action 1'),
        ),
        const PopupMenuItem(
          value: 'test2',
          child: Text('Test Action 2'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'change_type',
          child: Text('Change Type ▶'),
        ),
      ],
    );

    if (!context.mounted) return;

    if (result != null) {
      switch (result) {
        case 'test1':
          debugPrint('Test Action 1 clicked on column ${controller.columnName(col)}');
          break;
        case 'test2':
          debugPrint('Test Action 2 clicked on column ${controller.columnName(col)}');
          break;
        case 'change_type':
          await _showTypeMenu(context, controller, position, col);
          break;
      }
    }
  }

  Widget _buildColumnHeader(BuildContext context, SpreadsheetController controller, int col) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showColumnContextMenu(context, controller, details.globalPosition, col);
      },
      child: Container(
        width: cellWidth,
        height: headerHeight,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 1),
        color: Colors.grey.shade300,
        child: Text(
          controller.columnName(col),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildGrid(BuildContext context, SpreadsheetController controller) {
    // Dynamic size from controller
    final rows = controller.rowCount;
    final cols = controller.colCount;

    return Row(
      children: [
        // --- Row Header Column ---
        Column(
          children: [
            Container(
              width: headerWidth,
              height: headerHeight,
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  context.read<SpreadsheetController>().selectRange(
                    0, 0,
                    rows - 1,
                    cols - 1,
                  );
                },
                child: const Icon(Icons.select_all, size: 16),
              ),
            ),
            // Row headers
            Expanded(
              child: Scrollbar(
                controller: _verticalHeader,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _verticalHeader,
                  child: Column(
                    children: List.generate(rows, (row) {
                      return Container(
                        width: headerWidth,
                        height: cellHeight,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: 1),
                        color: Colors.grey.shade300,
                        child: Text("${row + 1}"),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),

        // --- Main Scrollable Area ----
        Expanded(
          child: Column(
            children: [
              // Column header row
              Scrollbar(
                controller: _horizontalHeader,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalHeader,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      cols,
                      (col) => _buildColumnHeader(context, controller, col),
                    ),
                  ),
                ),
              ),

              // Main grid scrollable in both directions
              Expanded(
                child: Scrollbar(
                  controller: _verticalBody,
                  thumbVisibility: true,
                  child: Scrollbar(
                    controller: _horizontalBody,
                    thumbVisibility: true,
                    notificationPredicate: (notif) => notif.depth == 1,
                    child: SingleChildScrollView(
                      controller: _verticalBody,
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        controller: _horizontalBody,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: cols * cellWidth,
                          height: rows * cellHeight,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              childAspectRatio: cellWidth / cellHeight,
                            ),
                            itemCount: rows * cols,
                            itemBuilder: (context, index) {
                              final row = index ~/ cols;
                              final col = index % cols;

                              final text = controller.getContent(row, col);
                              final isSelected = controller.isCellSelected(row, col);

                              return InkWell(
                                onTap: () {
                                  context
                                      .read<SpreadsheetController>()
                                      .selectCell(row, col);
                                  _focusNode.requestFocus();
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.all(1),
                                  color: isSelected
                                      ? Colors.blue.shade300
                                      : Colors.grey.shade200,
                                  child: Text(text),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}