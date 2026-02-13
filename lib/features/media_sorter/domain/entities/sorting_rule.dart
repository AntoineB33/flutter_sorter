
class SortingRule {
  final int minVal;
  final int maxVal;

  SortingRule({
    required this.minVal,
    required this.maxVal,
  });

  Map<String, dynamic> toJson() => {
        'min_val': minVal,
        'max_val': maxVal,
      };
  
  factory SortingRule.fromJson(Map<String, dynamic> json) {
    return SortingRule(
      minVal: json['min_val'],
      maxVal: json['max_val'],
    );
  }
}