import 'package:trying_flutter/features/media_sorter/data/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/data/models/update_data.dart';

abstract class SaveRepository {
  void saveUpdate(UpdateUnit update);
  void save(ChangeSet updates);
  void dispose();
}
