import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree/tree_controller.dart';

class SelectionManager extends ChangeNotifier {
  final SelectionController selectionController;
  final TreeController treeController;

  SelectionManager(this.selectionController, this.treeController) {
    selectionController.addListener(() {
      notifyListeners();
    });
  }

  void setPrimarySelection(
    int row,
    int col,
    bool keepSelection, {
    bool scrollTo = true,
  }) {
    selectionController.setPrimarySelection(row, col, keepSelection, scrollTo: scrollTo);
    
    treeController.updateMentionsContext(row, col);
  }
}