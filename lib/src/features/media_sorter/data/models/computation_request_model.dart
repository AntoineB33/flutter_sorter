class ComputationRequestModel {
  /// The raw text content of the entire grid
  final List<List<String>> rawGrid;
  
  /// The coordinates of the cells we want to analyze
  /// (e.g., Row 1 Col 2, Row 1 Col 3)
  final List<({int row, int col})> selectedCoordinates;

  ComputationRequestModel({
    required this.rawGrid,
    required this.selectedCoordinates,
  });
}