import 'package:json_annotation/json_annotation.dart';

part 'sort_progress_data.g.dart';

@JsonSerializable()
class SortProgressData {
  final List<int> bestSortFound;
  final List<int> cursors;
  final List<List<int>> possibleIntsById;
  final List<List<List<int>>> validAreasById;
  final List<int> bestDistFound;

  SortProgressData({required this.bestSortFound, required this.possibleIntsById, required this.cursors, required this.bestDistFound, required this.validAreasById});

  factory SortProgressData.empty(int n) {
    return SortProgressData(bestSortFound: [], possibleIntsById: List.generate(n, (_) => []), cursors: List.filled(n, 0), bestDistFound: [], validAreasById: List.generate(n + 1, (_) => []));
  }

  bool hasValidSort() {
    return bestDistFound.isNotEmpty;
  }

  bool hasMoreToExplore() {
    return cursors[0] < possibleIntsById[0].length;
  }

  factory SortProgressData.fromJson(Map<String, dynamic> json) =>
      _$SortProgressDataFromJson(json);

  Map<String, dynamic> toJson() => _$SortProgressDataToJson(this);
}
