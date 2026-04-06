import 'package:json_annotation/json_annotation.dart';

part 'sort_status.g.dart';

@JsonSerializable()
class SortStatus {
  final bool toApplyNextBestSort;
  final bool analysIsDone;

  SortStatus(
    this.toApplyNextBestSort,
    this.analysIsDone,
  );

  factory SortStatus.initial() {
    return SortStatus(false, false);
  }

  SortStatus copyWith({
    bool? toApplyNextBestSort,
    bool? toAlwaysApplyCurrentBestSort,
    bool? analysIsDone,
  }) {
    return SortStatus(
      toApplyNextBestSort ?? this.toApplyNextBestSort,
      toAlwaysApplyCurrentBestSort ?? this.toAlwaysApplyCurrentBestSort,
      analysIsDone ?? this.analysIsDone,
    );
  }

  factory SortStatus.fromJson(Map<String, dynamic> json) =>
      _$SortStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SortStatusToJson(this);
}
