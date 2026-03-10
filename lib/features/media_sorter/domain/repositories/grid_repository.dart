import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class GridRepository {
  void adjustRowHeightAfterUpdate(String sheetId, List<UpdateUnit> updateData);
}