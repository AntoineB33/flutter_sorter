import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trying_flutter/features/media_sorter/application/coordinators/spreadsheet_coordinator.dart';
import 'package:trying_flutter/features/media_sorter/application/state/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/media_sorter_injection.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/workbook_controller.dart';
import 'package:trying_flutter/shared/widgets/navigation_dropdown.dart';
import 'package:trying_flutter/features/media_sorter/presentation/widgets/side_menu/side_menu.dart';
import 'package:trying_flutter/shared/widgets/overlapping_split_view.dart';
import 'package:trying_flutter/features/media_sorter/presentation/widgets/spreadsheet/spreadsheet_widget.dart';

class MediaSorterPage extends StatelessWidget {

  const MediaSorterPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => slMediaSorter<SpreadsheetCoordinator>()),
        ChangeNotifierProvider(create: (_) => slMediaSorter<WorkbookController>()),
        ChangeNotifierProvider(create: (_) => slMediaSorter<TreeController>()),
        ChangeNotifierProvider(create: (_) => slMediaSorter<SortController>()),
        ChangeNotifierProvider(create: (_) => slMediaSorter<SheetDataController>()),
      ],
      child: Scaffold(
        appBar: const NavigationDropdown(),
        body: Consumer<SpreadsheetCoordinator>(
          builder: (context, coordinator, child) {
            if (coordinator.isPageReady == false) {
              return const Center(
                child: CircularProgressIndicator(), // Show spinner while waiting
              );
            }

            // 3. Build the actual page once data is ready
            return OverlappingSplitView(
              menuWidth: 250,
              leftSide: SideMenu(),
              rightSide: SpreadsheetWidget(
                slMediaSorter<GridController>(),
                slMediaSorter<SelectionController>(),
                slMediaSorter<WorkbookController>(),
                slMediaSorter<SheetDataController>(),
                slMediaSorter<TreeController>(),
                slMediaSorter<SpreadsheetCoordinator>(),
              ),
            );
          },
        ),
      ),
    );
  }
}
