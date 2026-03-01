import 'package:json_annotation/json_annotation.dart';

part 'sort_progress_data.g.dart';

@JsonSerializable()
class SortProgressData {
  List<List<int>> possibleIntsById;
  final List<int> cursors;
  final List<int> bestDistFound;

  SortProgressData({required this.possibleIntsById, required this.cursors, required this.bestDistFound});

  factory SortProgressData.empty() {
    return SortProgressData(possibleIntsById: [], cursors: [], bestDistFound: []);
  }

  factory SortProgressData.fromJson(Map<String, dynamic> json) =>
      _$SortProgressDataFromJson(json);

  Map<String, dynamic> toJson() => _$SortProgressDataToJson(this);
}
