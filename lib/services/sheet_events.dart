import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class SheetEvents {
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;

  /// Push a tiny event (does not store truth, just a ping)
  Future<void> publish({
    required String spreadsheetId,
    required int row,
    required String column,
    required String value,
  }) async {
    final ref = _rtdb.ref('events/$spreadsheetId').push();
    // Keep it tiny; include a server timestamp for ordering/TTL purge rules.
    await ref.set({
      'row': row,
      'column': column,
      'value': value,
      'ts': ServerValue.timestamp,
    });
  }

  /// Subscribe to new events for a sheet
  Stream<CellEvent> subscribe({required String spreadsheetId}) {
    final ref = _rtdb.ref('events/$spreadsheetId');
    // onChildAdded gives us new events only while online
    return ref.onChildAdded.map((e) {
      final d = (e.snapshot.value ?? {}) as Map<Object?, Object?>;
      return CellEvent(
        row: (d['row'] ?? 0) as int,
        column: (d['column'] ?? '') as String,
        value: (d['value'] ?? '').toString(),
      );
    });
  }
}

class CellEvent {
  final int row;
  final String column;
  final String value;
  CellEvent({required this.row, required this.column, required this.value});
}
