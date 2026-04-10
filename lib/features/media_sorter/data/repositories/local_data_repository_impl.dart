import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trying_flutter/features/media_sorter/data/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/local_data_source.dart';
import 'package:trying_flutter/features/media_sorter/data/store/layout_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/models/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/save_repository.dart';
import 'package:trying_flutter/utils/logger.dart';

class LocalDataRepositoryImpl
    with WidgetsBindingObserver
    implements SaveRepository {
  final ILocalDataSource _localDataSource;

  final LoadedSheetsCache sheetDataCache;
  final LayoutCache layoutCache;
  final SelectionCache selectionCache;

  // The Map acts as our cache. Using the entity's ID as the key
  // guarantees the "latest wins" behavior automatically.
  final Map<String, UpdateUnit> _pendingSaves = {};

  // The trigger for our debounce logic
  final PublishSubject<void> _saveTrigger = PublishSubject<void>();
  StreamSubscription? _saveSubscription;

  LocalDataRepositoryImpl(
    this._localDataSource,
    this.sheetDataCache,
    this.layoutCache,
    this.selectionCache,
  ) {
    // Listen to app lifecycle changes (pause, background, etc.)
    WidgetsBinding.instance.addObserver(this);

    // Set up the debounce listener
    _saveSubscription = _saveTrigger
        .debounceTime(
          const Duration(milliseconds: 500),
        ) // Adjust time as needed
        .listen((_) => _flushToDatabase());
  }

  @override
  void saveUpdate(UpdateUnit update) {
    save(ChangeSet()..addUpdate(update));
  }

  @override
  void save(ChangeSet updates) {
    for (var update in updates.toMap().values) {
      _pendingSaves.update(
        update.getKey(),
        (existing) => existing.merge(update),
        ifAbsent: () => update,
      );
      _saveTrigger.add(null);
    }
  }

  /// Takes the current cache, clears it, and writes to Drift
  Future<void> _flushToDatabase() async {
    if (_pendingSaves.isEmpty) return;

    // 1. Extract the items AND clear the map synchronously.
    // Doing this immediately prevents asynchronous race conditions where
    // a Use Case might add a new item while the DB is busy writing.
    final itemsToSave = _pendingSaves.values.toList();
    _pendingSaves.clear();

    // 2. Write to the database
    try {
      await _localDataSource.batchInsertOrUpdate(itemsToSave);
    } catch (e) {
      // ERROR HANDLING: If the save fails, we return the items to the cache.
      // We use putIfAbsent so we don't accidentally overwrite newer edits
      // that a user might have made while the DB was failing.
      for (var item in itemsToSave) {
        _pendingSaves.putIfAbsent(item.getKey(), () => item);
      }
      logger.e("Database save failed. Items returned to cache. Error: $e");
    }
  }

  /// App Lifecycle Hook
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the user minimizes the app or it gets killed, force a save immediately.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      logger.i("App going to background! Forcing emergency flush...");
      _flushToDatabase();
    }
  }

  /// Clean up when the repository is destroyed
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveSubscription?.cancel();
    _saveTrigger.close();
    // Do one final flush just in case
    _flushToDatabase();
  }
}
