import 'package:json_annotation/json_annotation.dart';

part 'sort_status.g.dart';

@JsonSerializable()
class SortStatus {
  final bool toApplyNextBestSort;
  final bool analysisDone;

  SortStatus(
    this.toApplyNextBestSort,
    this.analysisDone,
  );

  factory SortStatus.initial() {
    return SortStatus(false, false);
  }

  SortStatus copyWith({
    bool? toApplyNextBestSort,
    bool? toAlwaysApplyCurrentBestSort,
    bool? analysisDone,
  }) {
    return SortStatus(
      toApplyNextBestSort ?? this.toApplyNextBestSort,
      analysisDone ?? this.analysisDone,
    );
  }
  void _f(int y) {
    return;
  }
  void _fe(int y) {
    _f(y);
    return;
  }

  factory SortStatus.fromJson(Map<String, dynamic> json) =>
      _$SortStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SortStatusToJson(this);
}
