import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';

class SortUsecase extends ChangeNotifier {
  final SortRepository repository;

  Stream<void> call() => repository.progressStream;

  SortUsecase(this.repository);

  void sortMedia(String sheetId) {
    repository.sortMedia(sheetId);
  }

  void calculateOnChange() {
    repository.calculateOnChange();
  }
}