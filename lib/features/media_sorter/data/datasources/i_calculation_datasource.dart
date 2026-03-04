import 'dart:isolate';

import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';

abstract class ICalculationDataSource {
  static void solveSorting((SendPort, Map<int, Map<int, List<SortingRule>>>, SortProgressData) args);
}