import 'dart:async';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';


class SortProgressCache {
  final Map<String, SortProgressData> _dataBySheet = {};
  final _progressController = StreamController<void>.broadcast();
  
  Stream<void> get progressStream => _progressController.stream;

  SortProgressData getSortProgressData(String sheetId) {
    return _dataBySheet[sheetId]!;
  }

  void setBestSortFound(String sheetId, List<int> bestSortFound) {
    _dataBySheet[sheetId]!.bestSortFound
      ..clear()
      ..addAll(bestSortFound);
    _progressController.add(null);
  }
  
  void dispose() {
    _progressController.close();
  }
}
