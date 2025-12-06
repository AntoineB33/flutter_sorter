import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/local_spreadsheet_service.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

// Domain/Data imports
import '../controllers/spreadsheet_controller.dart';
import '../../domain/entities/column_type.dart';
import '../utils/column_type_extensions.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/spreadsheet_repository_impl.dart';
import 'package:trying_flutter/injection_container.dart';

class MediaSorterPage extends StatelessWidget {
  const MediaSorterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => sl<SpreadsheetController>(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Media Sorter (Optimized)")),
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
  final FocusNode _focusNode = FocusNode();
  
  // We utilize ScrollControllers provided by the TwoDimensionalScrollView 
  // if we need programmatic scrolling, otherwise TableView handles it.
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  static const double _defaultCellWidth = 100;
  static const double _defaultCellHeight = 40;
  static const double _headerHeight = 44;
  static const double _headerWidth = 60;

  @override
  void initState() {
    super.initState();
    // Ensure the grid can receive keyboard events immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SpreadsheetController>();

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) => _handleKeyboard(event, controller),
      child: TableView.builder(
        verticalDetails: ScrollableDetails.vertical(controller: _verticalController),
        horizontalDetails: ScrollableDetails.horizontal(controller: _horizontalController),
        
        // 1. PINNED HEADERS: This replaces LinkedScrollControllerGroup
        pinnedRowCount: 1, 
        pinnedColumnCount: 1,
        
        // 2. TOTAL COUNTS: +1 to account for the header row/column
        rowCount: controller.rowCount + 1,
        columnCount: controller.colCount + 1,

        // 3. SIZE BUILDERS
        columnBuilder: (index) => _buildColumnSpan(index),
        rowBuilder: (index) => _buildRowSpan(index),

        // 4. CELL BUILDER (The core logic)
        cellBuilder: (context, vicinity) {
          return _buildCell(context, vicinity, controller);
        },
      ),
    );
  }

  // --- Span Builders (Size definitions) ---

  TableSpan _buildColumnSpan(int index) {
    // Column 0 is the Row Header (1, 2, 3...)
    if (index == 0) {
      return const TableSpan(extent: FixedTableSpanExtent(_headerWidth));
    }
    return const TableSpan(extent: FixedTableSpanExtent(_defaultCellWidth));
  }

  TableSpan _buildRowSpan(int index) {
    // Row 0 is the Column Header (A, B, C...)
    if (index == 0) {
      return const TableSpan(extent: FixedTableSpanExtent(_headerHeight));
    }
    return const TableSpan(extent: FixedTableSpanExtent(_defaultCellHeight));
  }

  // --- Cell Builder (Content definitions) ---

  Widget _buildCell(
      BuildContext context, TableVicinity vicinity, SpreadsheetController controller) {
    
    final int renderRow = vicinity.row;
    final int renderCol = vicinity.column;

    // A. Top-Left Corner (Select All)
    if (renderRow == 0 && renderCol == 0) {
      return GestureDetector(
        onTap: () => controller.selectRange(0, 0, controller.rowCount - 1, controller.colCount - 1),
        child: Container(
          color: Colors.grey.shade300,
          alignment: Alignment.center,
          child: const Icon(Icons.select_all, size: 16),
        ),
      );
    }

    // B. Column Headers (A, B, C...) - Row 0
    if (renderRow == 0) {
      final int dataColIndex = renderCol - 1; // Adjust for pinned column
      return GestureDetector(
        onSecondaryTapDown: (details) {
          _showColumnContextMenu(context, controller, details.globalPosition, dataColIndex);
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            border: Border(
              right: BorderSide(color: Colors.grey.shade400),
              bottom: BorderSide(color: Colors.grey.shade400),
            ),
          ),
          child: Text(
            controller.columnName(dataColIndex),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // C. Row Headers (1, 2, 3...) - Column 0
    if (renderCol == 0) {
      final int dataRowIndex = renderRow - 1; // Adjust for pinned row
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          border: Border(
            right: BorderSide(color: Colors.grey.shade400),
            bottom: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        child: Text("${dataRowIndex + 1}"),
      );
    }

    // D. Actual Data Cells
    final int dataRow = renderRow - 1;
    final int dataCol = renderCol - 1;
    
    final bool isSelected = controller.isCellSelected(dataRow, dataCol);
    final String text = controller.getContent(dataRow, dataCol);

    return InkWell(
      onTap: () {
        controller.selectCell(dataRow, dataCol);
        _focusNode.requestFocus();
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.white,
          border: Border(
            right: BorderSide(color: Colors.grey.shade200),
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Text(text),
      ),
    );
  }
  
  // --- Logic & Menus ---

  Future<void> _handleKeyboard(KeyEvent event, SpreadsheetController ctrl) async {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey.keyLabel.toLowerCase();
    final isControl = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;

    if (isControl && key == 'c') {
      final copied = await ctrl.copySelectionToClipboard();
      if (copied != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Copied ${copied.split('\n').length} rows'), duration: const Duration(milliseconds: 500)),
        );
      }
    } else if (isControl && key == 'v') {
      final data = await Clipboard.getData('text/plain');
      if (data?.text != null) {
        ctrl.pasteText(data!.text!);
      }
    }
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
               Icon(Icons.circle, color: ColumnTypeX(entry).color, size: 12),
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
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: [
        const PopupMenuItem(value: 'sort_asc', child: Text('Sort A-Z')),
        const PopupMenuItem(value: 'sort_desc', child: Text('Sort Z-A')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'change_type', child: Text('Change Type ▶')),
      ],
    );

    if (!context.mounted) return;

    if (result == 'change_type') {
      await _showTypeMenu(context, controller, position, col);
    } else if (result != null) {
      debugPrint("Action $result on column $col");
    }
  }
}