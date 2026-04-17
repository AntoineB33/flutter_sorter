import 'package:json_annotation/json_annotation.dart';

part 'sort_progress_data.g.dart';

class SortProgressDataMsg {
  final SortProgressData sortProgressData;
  final bool newBestSortFound;

  SortProgressDataMsg(this.sortProgressData, this.newBestSortFound);
}

@JsonSerializable()
class SortProgressData {
  final List<int> bestSortFound;
  final List<int> cursors;
  final List<List<int>> possibleIntsById;
  final List<List<List<int>>> validAreasById;
  final List<int> bestDistFound;
  int sortIndex;

  SortProgressData({
    required this.bestSortFound,
    required this.possibleIntsById,
    required this.cursors,
    required this.bestDistFound,
    required this.validAreasById,
    required this.sortIndex,
  });

  factory SortProgressData.empty([int n = 0]) {
    return SortProgressData(
      bestSortFound: [],
      possibleIntsById: List.generate(n, (_) => []),
      cursors: List.filled(n, 0),
      bestDistFound: List.filled(n, 0),
      validAreasById: List.generate(n + 1, (_) => []),
      sortIndex: 0,
    );
  }

  bool hasValidSort() {
    return bestDistFound.isNotEmpty;
  }

  bool hasMoreToExplore() {
    return cursors.isNotEmpty && cursors[0] < possibleIntsById[0].length;
  }

  factory SortProgressData.fromJson(Map<String, dynamic> json) =>
      _$SortProgressDataFromJson(json);
  Map<String, dynamic> toJson() => _$SortProgressDataToJson(this);
  // ignore: unused_element
  static void _keepLinterHappy() => SortProgressData.empty().toJson();
}
