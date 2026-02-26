import 'package:json_annotation/json_annotation.dart';

part 'sort_status.g.dart';

@JsonSerializable()
class SortStatus {
  bool resultCalculated;
  bool validSortFound;
  bool toSort;
  bool isFindingBestSort;
  bool sortWhileFindingBestSort;

  SortStatus({
    required this.resultCalculated,
    required this.validSortFound,
    required this.toSort,
    required this.isFindingBestSort,
    required this.sortWhileFindingBestSort,
  });

  SortStatus.empty()
    : resultCalculated = true,
      validSortFound = true,
      toSort = false,
      isFindingBestSort = false,
      sortWhileFindingBestSort = false;

  factory SortStatus.fromJson(Map<String, dynamic> json) => 
      _$SortStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SortStatusToJson(this);
}