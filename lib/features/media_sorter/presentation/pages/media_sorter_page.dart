import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/workbook_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/delegates/spreadsheet_keyboard_delegate.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/selection_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/sort_status_data_store.dart';
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
        // 1. Data Controller (The Model)
        ChangeNotifierProvider(create: (_) => sl<WorkbookController>()),
        ChangeNotifierProvider(create: (_) => sl<TreeController>()),
      ],
      child: Scaffold(
        appBar: const NavigationDropdown(),
        body: ResizableSplitView(
          initialWidth: 250,
          minWidth: 150,
          maxWidth: 600,
          leftSide: SideMenu(),
          rightSide: SpreadsheetWidget(),
        ),
      ),
    );
  }
}
