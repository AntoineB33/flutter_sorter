class SortStatus {
  
  bool resultCalculated;
  bool validSortCalculated;
  bool toSort;
  bool isFindingBestSort;
  bool isFindingBestSortAndSort;

  SortStatus({
    required this.resultCalculated,
    required this.validSortCalculated,
    required this.toSort,
    required this.isFindingBestSort,
    required this.isFindingBestSortAndSort,
  });

  SortStatus.empty()
      : resultCalculated = true,
        validSortCalculated = true,
        toSort = false,
        isFindingBestSort = false,
        isFindingBestSortAndSort = false;

  factory SortStatus.fromJson(Map<String, dynamic> json) {
    return SortStatus(
      resultCalculated: json['resultCalculated'] as bool,
      validSortCalculated: json['validSortCalculated'] as bool,
      toSort: json['toSort'] as bool,
      isFindingBestSort: json['isFindingBestSort'] as bool,
      isFindingBestSortAndSort: json['isFindingBestSortAndSort'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resultCalculated': resultCalculated,
      'validSortCalculated': validSortCalculated,
      'toSort': toSort,
      'isFindingBestSort': isFindingBestSort,
      'isFindingBestSortAndSort': isFindingBestSortAndSort,
    };
  }
}