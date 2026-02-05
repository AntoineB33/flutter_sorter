
class SortingRule {
  final int minVal;
  final int maxVal;
  final int? relativeTo;

  SortingRule({
    required this.minVal,
    required this.maxVal,
    this.relativeTo,
  });

  Map<String, dynamic> toJson() => {
        'min_val': minVal,
        'max_val': maxVal,
        'relative_to': relativeTo,
      };
}