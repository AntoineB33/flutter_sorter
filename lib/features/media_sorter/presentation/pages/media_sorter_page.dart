import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trying_flutter/features/media_sorter/application/coordinators/spreadsheet_coordinator.dart';
import 'package:trying_flutter/features/media_sorter/application/state/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/workbook_controller.dart';
import 'package:trying_flutter/injection_container.dart';
import 'package:trying_flutter/shared/widgets/navigation_dropdown.dart';
import 'package:trying_flutter/features/media_sorter/presentation/widgets/side_menu/side_menu.dart';
import 'package:trying_flutter/shared/widgets/resizable_split_view.dart'; // Import the new widget
import 'package:trying_flutter/features/media_sorter/presentation/widgets/spreadsheet/spreadsheet_widget.dart';

class MediaSorterPage extends StatelessWidget {

  const MediaSorterPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<SpreadsheetCoordinator>()),
        ChangeNotifierProvider(create: (_) => sl<WorkbookController>()),
        ChangeNotifierProvider(create: (_) => sl<TreeController>()),
        ChangeNotifierProvider(create: (_) => sl<SortController>()),
        ChangeNotifierProvider(create: (_) => sl<SheetDataController>()),
      ],
      child: Scaffold(
        appBar: const NavigationDropdown(),
        body: ResizableSplitView(
          initialWidth: 250,
          minWidth: 150,
          maxWidth: 600,
          leftSide: SideMenu(),
          rightSide: SpreadsheetWidget(sl<GridController>(), sl<SelectionController>(), sl<WorkbookController>(), sl<SheetDataController>(), sl<TreeController>(), sl<SpreadsheetCoordinator>()),
        ),
      ),
    );
  }
}
