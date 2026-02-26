import 'package:json_annotation/json_annotation.dart';

part 'sort_progress_data.g.dart';

@JsonSerializable()
class SortProgressData {
  // Note: It's generally best practice to make entity fields 'final' 
  // unless you specifically need to mutate them directly.
  final List<int> choicesMade;
  final List<int> bestDistFound;

  SortProgressData({
    required this.choicesMade,
    required this.bestDistFound,
  });

  factory SortProgressData.empty() {
    return SortProgressData(
      choicesMade: [],
      bestDistFound: [],
    );
  }

  factory SortProgressData.fromJson(Map<String, dynamic> json) =>
      _$SortProgressDataFromJson(json);

  Map<String, dynamic> toJson() => _$SortProgressDataToJson(this);
}