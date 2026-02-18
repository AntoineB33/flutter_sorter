class SortStatus {
  bool resultCalculated;
  bool errorInResult;
  bool validSortCalculated;
  bool toSort;
  bool isFindingBestSort;
  bool sortWhileFindingBestSort;

  SortStatus({
    required this.resultCalculated,
    required this.errorInResult,
    required this.validSortCalculated,
    required this.toSort,
    required this.isFindingBestSort,
    required this.sortWhileFindingBestSort,
  });

  SortStatus.empty()
    : resultCalculated = true,
      errorInResult = false,
      validSortCalculated = true,
      toSort = false,
      isFindingBestSort = false,
      sortWhileFindingBestSort = false;

  factory SortStatus.fromJson(Map<String, dynamic> json) {
    return SortStatus(
      resultCalculated: json['resultCalculated'] as bool,
      errorInResult: json['errorInResult'] as bool,
      validSortCalculated: json['validSortCalculated'] as bool,
      toSort: json['toSort'] as bool,
      isFindingBestSort: json['isFindingBestSort'] as bool,
      sortWhileFindingBestSort: json['isFindingBestSortAndSort'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resultCalculated': resultCalculated,
      'errorInResult': errorInResult,
      'validSortCalculated': validSortCalculated,
      'toSort': toSort,
      'isFindingBestSort': isFindingBestSort,
      'isFindingBestSortAndSort': sortWhileFindingBestSort,
    };
  }
}
