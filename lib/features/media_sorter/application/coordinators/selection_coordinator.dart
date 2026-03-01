import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';

class SelectionCoordinator {
  final SelectionController selectionController;
  final SheetDataController sheetDataController;

  SelectionCoordinator(this.selectionController, this.sheetDataController);

  void startEditing({
    String? initialInput,
  }) {
    if (!selectionController.startEditing()) {
      return;
    }
    if (initialInput != null) {
      sheetDataController.onChanged(
        initialInput,
      );
    }
  }
}