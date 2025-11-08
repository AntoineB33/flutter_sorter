import 'package:cloud_firestore/cloud_firestore.dart';

class SheetStore {
  final _fs = FirebaseFirestore.instance;

  /// Get cells for a row range [startRow, endRow] inclusive
  Future<Map<String, String>> getRange({
    required String spreadsheetId,
    required int startRow,
    required int endRow,
  }) async {
    final snap = await _fs
        .collection('spreadsheets')
        .doc(spreadsheetId)
        .collection('cells')
        .where('row', isGreaterThanOrEqualTo: startRow)
        .where('row', isLessThanOrEqualTo: endRow)
        .get();

    final map = <String, String>{};
    for (final d in snap.docs) {
      final data = d.data();
      final key = '${data['row']}_${data['column']}';
      map[key] = (data['value'] ?? '').toString();
    }
    return map;
  }

  /// Set a single cell (authoritative write)
  Future<void> setCell({
    required String spreadsheetId,
    required int row,
    required String column,
    required String value,
  }) async {
    final cellsRef = _fs
        .collection('spreadsheets')
        .doc(spreadsheetId)
        .collection('cells');
    await cellsRef.doc('${row}_$column').set({
      'row': row,
      'column': column,
      'value': value,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
