import 'package:flutter/foundation.dart';

class FirestoreTelemetry {
  static final FirestoreTelemetry _instance = FirestoreTelemetry._internal();
  factory FirestoreTelemetry() => _instance;
  FirestoreTelemetry._internal();

  int writes = 0;
  int reads = 0;
  int bytesUploaded = 0;
  int bytesDownloaded = 0;

  void logWrite(Map<String, dynamic> data) {
    writes++;
    bytesUploaded += data.toString().length;
    debugPrint('[Firestore] Write #$writes (${data.length} fields)');
  }

  void logRead(Map<String, dynamic> data) {
    reads++;
    bytesDownloaded += data.toString().length;
    debugPrint('[Firestore] Read #$reads (${data.length} fields)');
  }

  void printSummary() {
    debugPrint(
      'Firestore telemetry summary: '
      '$writes writes, $reads reads, '
      '${bytesUploaded}B uploaded, ${bytesDownloaded}B downloaded.',
    );
  }
}
