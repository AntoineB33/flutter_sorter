import 'package:json_annotation/json_annotation.dart';

part 'sort_status.g.dart';

@JsonSerializable()
class SortStatus {
  bool toApplyOnce;
  bool toAlwaysApply;
  bool analysisDone;

  SortStatus({
    this.toApplyOnce = false,
    this.toAlwaysApply = false,
    this.analysisDone = true,
  });

  factory SortStatus.fromJson(Map<String, dynamic> json) =>
      _$SortStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SortStatusToJson(this);
}
