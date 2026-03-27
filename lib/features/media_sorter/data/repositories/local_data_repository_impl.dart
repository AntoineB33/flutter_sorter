import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/local_data_source.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/save_repository.dart';
import 'package:trying_flutter/utils/logger.dart';

class MergedInsertable<T extends Object> implements Insertable<T> {
  final Insertable<T> baseUpdate;
  final Insertable<T> newUpdate;

  MergedInsertable(this.baseUpdate, this.newUpdate);

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    // The newUpdate map will overwrite any matching keys in the baseUpdate map.
    return {
      ...baseUpdate.toColumns(nullToAbsent),
      ...newUpdate.toColumns(nullToAbsent),
    };
  }
}

/// Extension to make usage clean across your entire app.
extension MergeInsertableExt<T extends Object> on Insertable<T> {
  Insertable<T> merge(Insertable<T> other) => MergedInsertable(this, other);
}

class LocalDataRepositoryImpl
    with WidgetsBindingObserver
    implements SaveRepository {
  final ILocalDataSource _localDataSource;

  // The Map acts as our cache. Using the entity's ID as the key
  // guarantees the "latest wins" behavior automatically.
  final Map<Record, UpdateUnit> _pendingSaves = {};

  bool _isMicrotaskScheduled = false;

  // The trigger for our debounce logic
  final PublishSubject<void> _saveTrigger = PublishSubject<void>();
  StreamSubscription? _saveSubscription;

  LocalDataRepositoryImpl(this._localDataSource) {
    // Listen to app lifecycle changes (pause, background, etc.)
    WidgetsBinding.instance.addObserver(this);

    // Set up the debounce listener
    _saveSubscription = _saveTrigger
        .debounceTime(
          const Duration(milliseconds: 800),
        ) // Adjust time as needed
        .listen((_) => _flushToDatabase());
  }

  /// Called by your Use Cases
  @override
  void save(Map<Record, UpdateUnit> updates) {
    _pendingSaves.addAll(updates);

    // 2. Send a signal. RxDart will absorb rapid signals and only emit
    // to the listener once 800ms has passed with no new signals.
    if (!_isMicrotaskScheduled) {
      _isMicrotaskScheduled = true;
      scheduleMicrotask(() {
        _isMicrotaskScheduled = false;
        _saveTrigger.add(null); // Trigger the debounce stream
      });
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

  Future<List<int>> getRecentSheetIds() async {}

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
