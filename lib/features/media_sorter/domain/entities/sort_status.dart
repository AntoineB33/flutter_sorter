import 'package:json_annotation/json_annotation.dart';

part 'sort_status.g.dart';

@JsonSerializable()
class SortStatus {
  final bool toApplyNextBestSort;
  final bool toAlwaysApplyCurrentBestSort;
  final bool analysisDone;

  SortStatus(
    this.toApplyNextBestSort,
    this.toAlwaysApplyCurrentBestSort,
    this.analysisDone,
  );

  factory SortStatus.initial() {
    return SortStatus(false, false, false);
  }

  SortStatus copyWith({
    bool? toApplyNextBestSort,
    bool? toAlwaysApplyCurrentBestSort,
    bool? analysisDone,
  }) {
    return SortStatus(
      toApplyNextBestSort ?? this.toApplyNextBestSort,
      toAlwaysApplyCurrentBestSort ?? this.toAlwaysApplyCurrentBestSort,
      analysisDone ?? this.analysisDone,
    );
  }

  factory SortStatus.fromJson(Map<String, dynamic> json) =>
      _$SortStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SortStatusToJson(this);
}
