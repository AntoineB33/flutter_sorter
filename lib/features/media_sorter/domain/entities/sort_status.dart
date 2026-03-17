import 'package:json_annotation/json_annotation.dart';

part 'sort_status.g.dart';

@JsonSerializable()
class SortStatus {
  bool toApplyNextBestSort;
  bool toAlwaysApplyCurrentBestSort;
  bool analysisDone;

  SortStatus({
    this.toApplyNextBestSort = false,
    this.toAlwaysApplyCurrentBestSort = false,
    this.analysisDone = true,
  });

  factory SortStatus.fromJson(Map<String, dynamic> json) =>
      _$SortStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SortStatusToJson(this);
}
