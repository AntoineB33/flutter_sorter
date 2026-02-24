class SortProgressData {
  List<int> choicesMade;
  List<int> bestDistFound;

  static const String choicesMadeKey = 'choicesMade';
  static const String bestDistFoundKey = 'bestDistFound';

  SortProgressData({
    required this.choicesMade,
    required this.bestDistFound,
  });

  static SortProgressData empty() {
    return SortProgressData(
      choicesMade: [],
      bestDistFound: [],
    );
  }

  factory SortProgressData.fromJson(Map<String, dynamic> json) {
    return SortProgressData(
      choicesMade: List<int>.from(json[choicesMadeKey] as List<dynamic>),
      bestDistFound: List<int>.from(json[bestDistFoundKey] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      choicesMadeKey: choicesMade,
      bestDistFoundKey: bestDistFound,
    };
  }
}