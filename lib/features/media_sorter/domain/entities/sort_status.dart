class SortStatus {
  bool resultCalculated;
  bool validSortFound;
  bool toSort;
  bool isFindingBestSort;
  bool sortWhileFindingBestSort;

  static const String resultCalculatedKey = 'resultCalculated';
  static const String validSortFoundKey = 'validSortFound';
  static const String toSortKey = 'toSort';
  static const String isFindingBestSortKey = 'isFindingBestSort';
  static const String sortWhileFindingBestSortKey = 'sortWhileFindingBestSort';

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

  factory SortStatus.fromJson(Map<String, dynamic> json) {
    return SortStatus(
      resultCalculated: json[SortStatus.resultCalculatedKey] as bool,
      validSortFound: json[SortStatus.validSortFoundKey] as bool,
      toSort: json[SortStatus.toSortKey] as bool,
      isFindingBestSort: json[SortStatus.isFindingBestSortKey] as bool,
      sortWhileFindingBestSort: json[SortStatus.sortWhileFindingBestSortKey] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SortStatus.resultCalculatedKey: resultCalculated,
      SortStatus.validSortFoundKey: validSortFound,
      SortStatus.toSortKey: toSort,
      SortStatus.isFindingBestSortKey: isFindingBestSort,
      SortStatus.sortWhileFindingBestSortKey: sortWhileFindingBestSort,
    };
  }
}
