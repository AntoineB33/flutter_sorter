
class SortController {
  List<int>? _bestMediaSortOrder;

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