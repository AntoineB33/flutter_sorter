class SortStatus {
  
  bool resultCalculated;
  bool validSortCalculated;
  bool sorted;
  bool isFindingBestSort;
  bool isFindingBestSortAndSort;

  SortStatus({
    required this.resultCalculated,
    required this.validSortCalculated,
    required this.sorted,
    required this.isFindingBestSort,
    required this.isFindingBestSortAndSort,
  });

  SortStatus.empty()
      : resultCalculated = false,
        validSortCalculated = false,
        sorted = false,
        isFindingBestSort = false,
        isFindingBestSortAndSort = false;

  factory SortStatus.fromJson(Map<String, dynamic> json) {
    return SortStatus(
      resultCalculated: json['resultCalculated'] as bool,
      validSortCalculated: json['validSortCalculated'] as bool,
      sorted: json['sorted'] as bool,
      isFindingBestSort: json['isFindingBestSort'] as bool,
      isFindingBestSortAndSort: json['isFindingBestSortAndSort'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resultCalculated': resultCalculated,
      'validSortCalculated': validSortCalculated,
      'sorted': sorted,
      'isFindingBestSort': isFindingBestSort,
      'isFindingBestSortAndSort': isFindingBestSortAndSort,
    };
  }
}