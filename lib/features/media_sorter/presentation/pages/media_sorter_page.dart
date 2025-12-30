import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_controller.dart';
import 'package:trying_flutter/injection_container.dart';
import 'package:trying_flutter/shared/widgets/navigation_dropdown.dart';
import 'package:trying_flutter/features/media_sorter/presentation/widgets/side_menu/side_menu.dart';
import '../widgets/spreadsheet/spreadsheet_widget.dart';

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

            // 2. The Resizer Handle
            MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    final newWidth = _sidebarWidth + details.delta.dx;
                    _sidebarWidth = newWidth.clamp(_minSidebarWidth, _maxSidebarWidth);
                  });
                },
                child: Container(
                  width: 9,
                  alignment: Alignment.center,
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
            const Expanded(
              child: SpreadsheetWidget(),
            ),
          ],
        ),
      ),
    );
  }
}