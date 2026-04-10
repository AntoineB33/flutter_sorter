import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:trying_flutter/features/media_sorter/data/models/update_data.dart';

class ChangeSet {
  final Map<String, UpdateUnit> _changes;

  ChangeSet({IMap<String, UpdateUnit>? initialChanges})
    : _changes = initialChanges?.unlock ?? {};

  void addUpdate(UpdateUnit update) => _changes.update(
    update.getKey(),
    (existing) => existing.merge(update),
    ifAbsent: () => update,
  );

  void merge(ChangeSet other) {
    for (var update in other._changes.values) {
      addUpdate(update);
    }
  }

  IMap<String, UpdateUnit> toMap() => _changes.lock;
  bool get hasChanges => _changes.isNotEmpty;
}
