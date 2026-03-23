import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class SaveRepository {
  void save(Map<String, UpdateUnit> updates);
}