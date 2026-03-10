import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class HistoryRepository {
  void moveInUpdateHistory(int direction);
  void commitHistory(UpdateData updateData);
  void setCellContent(int rowId, int colId, String prevVal, String newVal);
}