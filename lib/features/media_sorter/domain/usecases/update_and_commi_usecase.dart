import 'package:trying_flutter/features/media_sorter/domain/usecases/history_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data_usecase.dart';

class UpdateAndCommiUsecase {
  SheetDataUsecase sheetDataUsecase;
  HistoryUsecase historyUsecase;

  UpdateAndCommiUsecase(
    this.sheetDataUsecase,
    this.historyUsecase,
  );

  void setCellContent(String newValue, int sheetId) {
    final update = sheetDataUsecase.setCellContent(newValue, sheetId);
    sheetDataUsecase.applyUpdatesNoSort(
      IMap<String, SyncRequest>({update.id: update}),
      sheetId,
      false,
      true,
    );
    historyUsecase.commitHistory(update, sheetId);
  }
}