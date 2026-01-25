import 'dart:math';
import 'package:flutter/services.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_model.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/spreadsheet_scroll_request.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/grid_history_selection_data_tree_stream_manager.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/tree_structure_builder.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/check_valid_strings.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/get_default_sizes.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart'; // Import AnalysisResult
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/utils/logger.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';

class SpreadsheetKeyboardDelegate {
  final GridHistorySelectionDataTreeStreamManager manager;

  SpreadsheetKeyboardDelegate(this.manager);

  KeyEventResult handle(BuildContext context, KeyEvent event) {
    if (manager.editingMode) return KeyEventResult.ignored;
    if (event is KeyUpEvent) return KeyEventResult.ignored;

    final logicalKey = event.logicalKey;
    final isControl = HardwareKeyboard.instance.isControlPressed;

    // Navigation
    if (logicalKey == LogicalKeyboardKey.arrowUp) {
      manager.moveSelection(-1, 0);
      return KeyEventResult.handled;
    }
    // ... other arrows ...

    // Shortcuts
    if (isControl) {
      switch (event.logicalKey.keyLabel.toLowerCase()) {
        case 'c':
          manager.copySelection(); 
          return KeyEventResult.handled;
        case 'v':
          manager.pasteSelection();
          return KeyEventResult.handled;
        case 'z':
          manager.undo();
          return KeyEventResult.handled;
        // ...
      }
    }

    // Typing
    if (_isPrintable(event)) {
      manager.startEditing(initialInput: event.character);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  bool _isPrintable(KeyEvent event) {
    // ... logic ...
  }
}