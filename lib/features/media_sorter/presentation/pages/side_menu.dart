import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import '../controllers/spreadsheet_data_controller.dart';
import '../controllers/analysis_controller.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  late TextEditingController _textEditingController;
  late ScrollController _verticalController;
  late ScrollController _horizontalController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _verticalController = ScrollController();
    _horizontalController = ScrollController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  // ... _handleScroll method remains the same ...

  Widget _buildNodeTree(BuildContext context, NodeStruct node, AnalysisController controller) {
    // ... Implementation remains the same, just accepts AnalysisController ...
    // Calls controller.toggleNodeExpansion(node, !isExpanded)
    return Container(); // Placeholder for brevity, copy original logic
  }

  @override
  Widget build(BuildContext context) {
    // Access the specific controllers
    final dataCtrl = context.watch<SpreadsheetDataController>();
    final analysisCtrl = context.watch<AnalysisController>();

    if (_textEditingController.text != dataCtrl.sheetName && !dataCtrl.isLoading) {
      _textEditingController.text = dataCtrl.sheetName;
    }

    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sheet Manager", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Autocomplete uses DataController
          LayoutBuilder(
            builder: (context, constraints) {
              return Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  // Logic using dataCtrl.availableSheets
                   return []; // Copy logic from original
                },
                onSelected: (String selection) {
                  dataCtrl.loadSheetByName(selection);
                },
                // ... remaining field setup using dataCtrl ...
              );
            },
          ),
          
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          const Text("Analysis Logs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Tree uses AnalysisController
          Expanded(
            child: SingleChildScrollView(
              // ... scrolling logic ...
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildNodeTree(context, analysisCtrl.errorRoot, analysisCtrl),
                   _buildNodeTree(context, analysisCtrl.warningRoot, analysisCtrl),
                   _buildNodeTree(context, analysisCtrl.mentionsRoot, analysisCtrl),
                   // ... etc
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}