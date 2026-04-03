import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

class ChangeSet {
  final Map<String, UpdateUnit> _changes = {};

  void addUpdate(UpdateUnit update) => _changes[update.getKey()] = update;

  Map<String, UpdateUnit> toMap() => Map.unmodifiable(_changes);
  bool get hasChanges => _changes.isNotEmpty;
}