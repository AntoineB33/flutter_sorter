import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_controller.dart';
import 'package:trying_flutter/injection_container.dart';
import 'package:trying_flutter/shared/widgets/navigation_dropdown.dart';
import 'package:trying_flutter/features/media_sorter/presentation/widgets/side_menu/side_menu.dart';
import 'package:trying_flutter/shared/widgets/resizable_split_view.dart'; // Import the new widget
import 'package:trying_flutter/features/media_sorter/presentation/widgets/spreadsheet/spreadsheet_widget.dart';

class MediaSorterPage extends StatelessWidget {
  const MediaSorterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => sl<SpreadsheetController>(),
      child: const Scaffold(
        appBar: NavigationDropdown(),
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