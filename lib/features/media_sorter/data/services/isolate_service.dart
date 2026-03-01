import 'dart:async';
import 'dart:isolate';

import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_response.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort/sort_usecase.dart';

class IsolateService {
  Isolate? _isolateB;
  Isolate? _isolateC;

  // We use Completers to handle the "result" promise which we might need to
  // abandon if the isolate is killed.
  ReceivePort? _portB;
  ReceivePort? _portC;

  IsolateService();

  void cancelB() {
    if (_isolateB != null) {
      _isolateB!.kill(priority: Isolate.immediate);
      _isolateB = null;
    }
    if (_portB != null) {
      _portB!.close();
      _portB = null;
    }
  }

  void cancelC() {
    if (_isolateC != null) {
      // Kill the isolate immediately
      _isolateC?.kill(priority: Isolate.immediate);
      _isolateC = null;
    }
    // Close the ReceivePort to prevent memory leaks
    if (_portC != null) {
      _portC?.close();
      _portC = null;
    }
  }

  Future<AnalysisReturn> runHeavyCalculationB(
    SheetContent sheetContent,
    AnalysisResult result,
  ) async {
    final receivePort = ReceivePort();
    _portB = receivePort;

    _isolateB = await Isolate.spawn(CalculationService.runCalculation, [
      receivePort.sendPort,
      sheetContent,
      result,
    ]);

    AnalysisReturn analysisReturn = await receivePort.first;
    _isolateB = null;
    return analysisReturn;
  }

  Stream<SortingResponse> findBestSort(
    Map<int, Map<int, List<SortingRule>>> rules,
    List<List<int>> validAreas,
    int n,
    bool isFindingBestSort,
  ) async* {
    // 1. Create a ReceivePort to listen for messages from the isolate
    _portC = ReceivePort();

    // 2. Listen to the port
    _portC?.listen(outputReceiver);

    // 3. Spawn the isolate, passing the SendPort so it knows where to send data
    try {
      final arguments = (_portC!.sendPort, rules, validAreas, n);
    _isolateC = await Isolate.spawn(SortUsecase.solveSorting, arguments);
    } catch (e) {
      cancelC();
    }
  }

}
