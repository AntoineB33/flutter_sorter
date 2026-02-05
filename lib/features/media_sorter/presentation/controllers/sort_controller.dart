import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';

class SortController {
  Map<int, List<SortingRule>> myRules = {};
  List<int>? _bestMediaSortOrder;
  bool findingBestSort = false;

  List<int>? get bestMediaSortOrder => _bestMediaSortOrder;

  SortController();

  void clear() {
    _bestMediaSortOrder = null;
  }

  void setBestMediaSortOrder(List<int> order) {
    _bestMediaSortOrder = order;
  }

  bool canBeSorted() {
    return _bestMediaSortOrder != null;
  }

}