import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/application/state/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';

class TreeCoordinator extends ChangeNotifier {
  final AnalysisResultCache analysisDataStore;
  final TreeController treeController;
  final SelectionController selectionController;

  TreeCoordinator(
    this.analysisDataStore,
    this.treeController,
    this.selectionController,
  ) {
    treeController.addListener(notifyListeners);
  }

  @override
  void dispose() {
    treeController.removeListener(notifyListeners);
    super.dispose();
  }
}
