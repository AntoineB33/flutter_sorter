import 'package:trying_flutter/features/media_sorter/core/entities/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class SaveRepository {
  void saveUpdate(UpdateUnit update);
  void save(ChangeSet updates);
  void dispose();
}