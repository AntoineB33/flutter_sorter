import 'package:json_annotation/json_annotation.dart';

part 'sort_status.g.dart';

@JsonSerializable()
class SortStatus {
  bool toSort;
  bool isFindingBestSort;
  bool analysisDone;

  SortStatus({
    this.toSort = false,
    this.isFindingBestSort = false,
    this.analysisDone = false,
  });

  factory SortStatus.fromJson(Map<String, dynamic> json) =>
      _$SortStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SortStatusToJson(this);
}
