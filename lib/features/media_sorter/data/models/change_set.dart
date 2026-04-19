import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';

@JsonSerializable(explicitToJson: true)
class ChangeSetImpl implements ChangeSet {
  final Map<String, SyncRequestImpl> _changes;

  ChangeSetImpl({IMap<String, SyncRequestImpl>? initialChanges})
    : _changes = initialChanges?.unlock ?? {};

  void addUpdate(SyncRequestImpl update) => _changes.update(
    update.getKey(),
    (existing) => existing.merge(update),
    ifAbsent: () => update,
  );

  @override
  void merge(ChangeSet other) {
    for (var update in (other as ChangeSetImpl)._changes.values) {
      addUpdate(update);
    }
  }

  @override
  IMap<String, SyncRequest> toMap() => _changes.lock;
  @override
  bool get hasChanges => _changes.isNotEmpty;

  factory ChangeSetImpl.fromJson(Map<String, dynamic> json) =>
      _$ChangeSetImplFromJson(json);
  Map<String, dynamic> toJson() => _$ChangeSetImplToJson(this);
  // ignore: unused_element
  static void _keepLinterHappy() => ChangeSetImpl().toJson();
}
