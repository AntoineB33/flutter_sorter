import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';

@JsonSerializable(explicitToJson: true)
class ChangeSet {
  final Map<String, SyncRequest> _changes;

  ChangeSet({IMap<String, SyncRequest>? initialChanges})
    : _changes = initialChanges?.unlock ?? {};

  void addUpdate(SyncRequest update) => _changes.update(
    update.getKey(),
    (existing) => existing.merge(update),
    ifAbsent: () => update,
  );

  void merge(ChangeSet other) {
    for (var update in other._changes.values) {
      addUpdate(update);
    }
  }

  IMap<String, SyncRequest> toMap() => _changes.lock;
  bool get hasChanges => _changes.isNotEmpty;
}
