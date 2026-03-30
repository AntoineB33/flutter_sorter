import 'package:json_annotation/json_annotation.dart';

part 'sort_status.g.dart';

@JsonSerializable()
class SortStatus {
  bool toApplyNextBestSort;
  bool toAlwaysApplyCurrentBestSort;
  bool analysisDone;

  SortStatus(
    this.toApplyNextBestSort,
    this.toAlwaysApplyCurrentBestSort,
    this.analysisDone,
  );

  factory SortStatus.initial() {
    return SortStatus(false, false, false);
  }

  factory SortStatus.fromJson(Map<String, dynamic> json) =>
      _$SortStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SortStatusToJson(this);
}
