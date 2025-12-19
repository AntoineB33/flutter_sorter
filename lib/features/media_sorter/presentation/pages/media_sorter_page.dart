import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import '../controllers/spreadsheet_controller.dart';
import 'package:trying_flutter/injection_container.dart';
import '../../../../shared/widgets/navigation_dropdown.dart';
import 'side_menu.dart';
import '../../domain/entities/column_type.dart';
import '../utils/column_type_extensions.dart';

class MediaSorterPage extends StatelessWidget {
  const MediaSorterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => sl<SpreadsheetController>(),
      child: Scaffold(
        appBar: const NavigationDropdown(),
        // 1. Change Body to a Row to support Sidebar + Content
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. The Sidebar
            const SizedBox(
              width: 250, // Set your desired sidebar width
              child: SideMenu(),
            ),
            
            // Optional: A vertical divider for visual separation
            const VerticalDivider(width: 1, thickness: 1),

            // 3. The Spreadsheet (Wrapped in Expanded)
            const Expanded(
              child: SpreadsheetWidget(),
            ),
          ],
        ),
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
      onKeyEvent: (KeyEvent event) => _handleKeyboard(context, event, controller),
      child: TableView.builder(
        verticalDetails: ScrollableDetails.vertical(controller: _verticalController),
        horizontalDetails: ScrollableDetails.horizontal(controller: _horizontalController),
        
        // 1. PINNED HEADERS: This replaces LinkedScrollControllerGroup
        pinnedRowCount: 1, 
        pinnedColumnCount: 1,
        
        // 2. TOTAL COUNTS: +1 to account for the header row/column
        rowCount: controller.tableViewRows + 1,
        columnCount: controller.tableViewCols + 1,

        // 3. SIZE BUILDERS
        columnBuilder: (index) => _buildColumnSpan(index),
        rowBuilder: (index) => _buildRowSpan(index),

        // 4. CELL BUILDER (The core logic)
        cellBuilder: (context, vicinity) => _buildCellDispatcher(context, vicinity, controller),
      ),
    );
  }

  void _handleKeyboard(BuildContext context, KeyEvent event, SpreadsheetController ctrl) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey.keyLabel.toLowerCase();
    final isControl = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;

    if (isControl && key == 'c') {
      ctrl.copySelectionToClipboard(); // Logic moved to controller
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Selection copied'), duration: Duration(milliseconds: 500)),
      );
    } else if (isControl && key == 'v') {
      ctrl.pasteSelection(); // Logic moved to controller
    }
  }

  // --- Span Builders (Size definitions) ---
  TableSpan _buildColumnSpan(int index) {
    return TableSpan(
      extent: FixedTableSpanExtent(index == 0 ? _headerWidth : _defaultCellWidth),
    );
  }

  TableSpan _buildRowSpan(int index) {
    return TableSpan(
      extent: FixedTableSpanExtent(index == 0 ? _headerHeight : _defaultCellHeight),
    );
  }

  // --- 3. WIDGET COMPOSITION: Dispatcher splits logic for readability ---
  Widget _buildCellDispatcher(
      BuildContext context, TableVicinity vicinity, SpreadsheetController controller) {
    
    final int r = vicinity.row;
    final int c = vicinity.column;

    if (r == 0 && c == 0) {
      return _SelectAllCorner(onTap: () => controller.selectAll());
    }
    if (r == 0) {
      return _ColumnHeader(
        label: controller.getColumnLabel(c - 1),
        colIndex: c - 1,
        onContextMenu: (details) => _showColumnContextMenu(context, controller, details.globalPosition, c - 1),
      );
    }
    if (c == 0) {
      return _RowHeader(rowIndex: r - 1);
    }

    // Standard Data Cell
    return _DataCell(
      row: r - 1,
      col: c - 1,
      content: controller.getContent(r - 1, c - 1),
      isSelected: controller.isCellSelected(r - 1, c - 1),
      onTap: () {
        controller.selectCell(r - 1, c - 1);
        _focusNode.requestFocus();
      },
    );
  }

  // --- Menus (View Logic) ---
  
  
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

  void _showColumnContextMenu(BuildContext context, SpreadsheetController controller, 
      Offset position, int col) async {
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


class _SelectAllCorner extends StatelessWidget {
  final VoidCallback onTap;
  const _SelectAllCorner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: const Icon(Icons.select_all, size: 16),
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  final String label;
  final int colIndex;
  final Function(TapDownDetails) onContextMenu;

  const _ColumnHeader({required this.label, required this.colIndex, required this.onContextMenu});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: onContextMenu,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          border: Border(
            right: BorderSide(color: Colors.grey.shade400),
            bottom: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _RowHeader extends StatelessWidget {
  final int rowIndex;
  const _RowHeader({required this.rowIndex});

  @override
  Widget build(BuildContext context) {
    // 1. Define the logic: If it's the first row (index 0), show a String.
    // Otherwise, show the calculated number.
    final String label = (rowIndex == 0) ? "Headers" : "$rowIndex";

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        border: Border(
          right: BorderSide(color: Colors.grey.shade400),
          bottom: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      child: Text(
        label,
        // Optional: reduce font size slightly if the string is long
        style: TextStyle(
          fontWeight: rowIndex == 0 ? FontWeight.bold : FontWeight.normal,
          fontSize: rowIndex == 0 ? 12 : 14,
        ),
      ),
    );
  }
}
class _DataCell extends StatelessWidget {
  final int row;
  final int col;
  final String content;
  final bool isSelected;
  final VoidCallback onTap;

  const _DataCell({
    required this.row,
    required this.col,
    required this.content,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.white,
          border: Border(
            right: BorderSide(color: Colors.grey.shade200),
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Text(content),
      ),
    );
  }
}