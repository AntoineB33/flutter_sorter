import 'package:json_annotation/json_annotation.dart';

part 'sort_progress_data.g.dart';

@JsonSerializable()
class SortProgressData {
  final List<int> cursors;
  final List<List<int>> possibleIntsById;
  final List<List<List<int>>> validAreasById;
  final List<int> bestDistFound;

  SortProgressData({required this.possibleIntsById, required this.cursors, required this.bestDistFound, required this.validAreasById});

  factory SortProgressData.empty(int n) {
    return SortProgressData(possibleIntsById: List.generate(n, (_) => []), cursors: List.filled(n, 0), bestDistFound: [], validAreasById: List.generate(n + 1, (_) => []));
  }

  factory SortProgressData.fromJson(Map<String, dynamic> json) =>
      _$SortProgressDataFromJson(json);

  Map<String, dynamic> toJson() => _$SortProgressDataToJson(this);
}
