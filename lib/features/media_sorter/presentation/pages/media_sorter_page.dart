import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import '../../../../shared/widgets/navigation_dropdown.dart';
import '../../data/repositories/spreadsheet_repository_impl.dart';
import '../../domain/usecases/get_sheet_data_usecase.dart';
import '../controllers/spreadsheet_controller.dart';

class MediaSorterPage extends StatefulWidget {
  const MediaSorterPage({super.key});

  @override
  State<MediaSorterPage> createState() => _MediaSorterPageState();
}

class _MediaSorterPageState extends State<MediaSorterPage> {
  late SpreadsheetController _controller;
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    // In a real app, use a Dependency Injection container (GetIt/Provider/Riverpod)
    // to obtain these instances.
    final repo = SpreadsheetRepositoryImpl();
    final useCase = GetSheetDataUseCase(repo);
    _controller = SpreadsheetController(getDataUseCase: useCase);
    
    _controller.loadData();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavigationDropdown(),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Toolbar
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.grey[200],
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _controller.addRows(1000),
                      child: const Text("Add 1000 Rows"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _controller.addColumns(10),
                      child: const Text("Add 10 Cols"),
                    ),
                    const Spacer(),
                    Text("Dims: ${_controller.rowCount} x ${_controller.colCount}"),
                  ],
                ),
              ),
              // The 2D Table
              Expanded(
                child: TableView.builder(
                  verticalDetails: ScrollableDetails.vertical(controller: _verticalController),
                  horizontalDetails: ScrollableDetails.horizontal(controller: _horizontalController),
                  columnCount: _controller.colCount,
                  rowCount: _controller.rowCount,
                  pinnedRowCount: 1, // Header row
                  pinnedColumnCount: 1, // Index column
                  columnBuilder: (index) => const TableSpan(
                    extent: FixedTableSpanExtent(100),
                    backgroundDecoration: TableSpanDecoration(
                      border: TableSpanBorder(trailing: BorderSide(color: Colors.black12)),
                    ),
                  ),
                  rowBuilder: (index) => const TableSpan(
                    extent: FixedTableSpanExtent(50),
                    backgroundDecoration: TableSpanDecoration(
                      border: TableSpanBorder(trailing: BorderSide(color: Colors.black12)),
                    ),
                  ),
                  cellBuilder: (context, vicinity) {
                    final isHeaderRow = vicinity.row == 0;
                    final isIndexCol = vicinity.column == 0;

                    if (isHeaderRow) {
                      return Center(child: Text("Col ${vicinity.column}", style: const TextStyle(fontWeight: FontWeight.bold)));
                    }
                    if (isIndexCol) {
                      return Center(child: Text("Row ${vicinity.row}", style: const TextStyle(fontWeight: FontWeight.bold)));
                    }

                    return Center(
                      child: Text(_controller.getContent(vicinity.row, vicinity.column)),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}