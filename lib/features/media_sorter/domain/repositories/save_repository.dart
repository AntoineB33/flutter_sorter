import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class SaveRepository {
  void saveUpdate(UpdateUnit update);
  void save(Map<String, UpdateUnit> updates, int sheetId);
  void dispose();
}