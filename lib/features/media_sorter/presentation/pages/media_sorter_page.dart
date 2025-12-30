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

class MediaSorterPage extends StatefulWidget {
  const MediaSorterPage({super.key});

  @override
  State<MediaSorterPage> createState() => _MediaSorterPageState();
}

class _MediaSorterPageState extends State<MediaSorterPage> {
  // Default width
  double _sidebarWidth = 250.0;
  
  // Constraints
  static const double _minSidebarWidth = 150.0;
  static const double _maxSidebarWidth = 600.0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => sl<SpreadsheetController>(),
      child: Scaffold(
        appBar: const NavigationDropdown(),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. The Resizable Sidebar
            SizedBox(
              width: _sidebarWidth,
              child: const SideMenu(),
            ),

            // 2. The Resizer Handle (The "Draggable Border")
            MouseRegion(
              cursor: SystemMouseCursors.resizeColumn, // Changes cursor to <->
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    // Adjust width based on drag delta
                    final newWidth = _sidebarWidth + details.delta.dx;
                    // Clamp to prevent breaking UI
                    _sidebarWidth = newWidth.clamp(_minSidebarWidth, _maxSidebarWidth);
                  });
                },
                // We create a container that is wider than the visible line
                // to make it easier for the user to grab (hitbox).
                child: Container(
                  width: 9, 
                  alignment: Alignment.center,
                  // The container is transparent, but holds the visual divider
                  color: Colors.transparent, 
                  child: Container(
                    width: 1,
                    height: double.infinity,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),

            // 3. The Spreadsheet
            // Because this is Expanded, it will automatically shrink/grow/move
            // as the sidebar (sibling) changes size.
            const Expanded(
              child: SpreadsheetWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The rest of the file remains exactly the same as your provided code
// ---------------------------------------------------------------------------

class SpreadsheetWidget extends StatefulWidget {
  const SpreadsheetWidget({super.key});

  @override
  State<SpreadsheetWidget> createState() => _SpreadsheetWidgetState();
}

class _SpreadsheetWidgetState extends State<SpreadsheetWidget> {
  final FocusNode _focusNode = FocusNode();
  
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  static const double _defaultCellWidth = 100;
  static const double _defaultCellHeight = 40;
  static const double _headerHeight = 44;
  static const double _headerWidth = 60;

  @override
  void initState() {
    super.initState();
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
        
        pinnedRowCount: 1, 
        pinnedColumnCount: 1,
        
        rowCount: controller.tableViewRows + 1,
        columnCount: controller.tableViewCols + 1,

        columnBuilder: (index) => _buildColumnSpan(index),
        rowBuilder: (index) => _buildRowSpan(index),

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
      ctrl.copySelectionToClipboard();
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Selection copied'), duration: Duration(milliseconds: 500)),
      );
    } else if (isControl && key == 'v') {
      ctrl.pasteSelection();
    }
  }

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