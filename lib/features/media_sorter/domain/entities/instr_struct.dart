import 'package:collection/collection.dart';


class InstrStruct {
  bool isConstraint;
  bool any;
  List<int> numbers;
  List<List<int>> intervals;

  static const _equality = DeepCollectionEquality();

  InstrStruct(
    this.isConstraint,
    this.any,
    this.numbers,
    this.intervals
  );
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is InstrStruct &&
        isConstraint == other.isConstraint &&
        any == other.any &&
        // 2. Use .equals to compare the contents of the lists
        _equality.equals(other.numbers, numbers) &&
        _equality.equals(other.intervals, intervals);
  }

  @override
  int get hashCode => Object.hash(
        isConstraint,
        any,
        // 3. Use .hash separately for the lists
        _equality.hash(numbers),
        _equality.hash(intervals),
      );
  
  factory InstrStruct.fromJson(Map<String, dynamic> json) {
    return InstrStruct(
      json['isConstraint'] as bool,
      json['any'] as bool,
      List<int>.from(json['numbers'] as List<dynamic>),
      (json['intervals'] as List<dynamic>)
          .map((e) => List<int>.from(e as List<dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isConstraint': isConstraint,
      'any': any,
      'numbers': numbers,
      'intervals': intervals,
    };
  }
}
