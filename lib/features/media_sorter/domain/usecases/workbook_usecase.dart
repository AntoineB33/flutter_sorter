import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/data_load_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';
import 'package:trying_flutter/utils/logger.dart';

class WorkbookUseCase {
  final WorkbookRepository workbookRepository;
  final SelectionRepository selectionRepository;
  final SortRepository sortRepository;

  WorkbookUseCase(this.workbookRepository, this.selectionRepository, this.sortRepository);

  Future<void> init() async {
    Either<Failure, DataLoadResult> workbookInitResult = await workbookRepository.init();
    workbookInitResult.fold(
      (failure) {
        logger.e("Failed to initialize workbook repository");
      },
      (dataLoadResult) {
        if (dataLoadResult == DataLoadResult.corruptedButRecovered) {
          logger.w("Workbook data was corrupted but has been recovered. Some data may have been lost.");
        } else {
          logger.i("Workbook repository initialized successfully.");
        }
      },
    );
    selectionRepository.getAllLastSelected();
    selectionRepository.init();
    sortRepository.init();
    workbookRepository.checkSortStatusSheetIds();
    selectionRepository.loadLastSelection();
  }
}