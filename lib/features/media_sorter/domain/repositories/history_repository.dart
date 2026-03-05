import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class HistoryRepository {
  Stream<UpdateRequest> get updateDataStream;
  void moveInUpdateHistory(int direction);
  void commitHistory(UpdateData updateData);
}