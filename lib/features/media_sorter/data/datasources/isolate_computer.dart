// import 'dart:async';
// import 'package:flutter/foundation.dart'; // Contains 'compute'
// import '../../domain/entities/analysis_result.dart';
// import 'package:trying_flutter/features/media_sorter/data/models/isolate_messages.dart';


// class IsolateComputer {
//   /// This method is called by the Repository
//   Future<AnalysisResult> runHeavyCalculation(IsolateMessage message) async {
//     // 'compute' spawns an isolate, runs _heavyTask, and returns the result.
//     return compute(_heavyTask, message);
//   }

//   /// ⚠️ STATIC or TOP-LEVEL function.
//   /// This runs in a separate memory space. It cannot access other classes/widgets.
//   static AnalysisResult _heavyTask(IsolateMessage message) {
//     final Object dataPackage = switch (message) {
//       RawDataMessage m => m.table,
//       TransferableDataMessage m => m.dataPackage,
//     };
//     final worker = _AnalysisWorker(dataPackage, message.columnTypes);
//     return worker.run();
//   }
// }
