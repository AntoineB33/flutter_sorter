import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

class AddUpdate {
  static void addUpdate(Map<String, UpdateUnit> updates, UpdateUnit newUpdate) {
    updates.update(newUpdate.getKey(), (existing) => existing.merge(newUpdate), ifAbsent: () => newUpdate);
  }
}