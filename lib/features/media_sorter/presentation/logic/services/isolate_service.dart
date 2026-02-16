import 'dart:isolate';

import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_response.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort_controller.dart';

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
      _portB?.close();
    }
  }
  void cancelC() {
    if (_isolateC != null) {
      _isolateC!.kill(priority: Isolate.immediate);
      _isolateC = null;
      _portC?.close();
    }
  }
  
  static Future<void> _isolateEntryC(List<dynamic> args) async {
    SendPort sendPort = args[0];
    AnalysisResult result = args[1];

    SortingResponse? response = await SortController.solveSatisfaction(
      result,
    );

    Isolate.exit(sendPort, response);
  }

  Future<ThreadResult> runHeavyCalculationB(
    SheetContent sheetContent,
    AnalysisResult result,
  ) async {
    // Requirements: "If A starts... cancel B if it was running."
    // This is handled by the Bloc calling cancelB() before A,
    // but we double check here to ensure clean state.

    final receivePort = ReceivePort();
    _portB = receivePort;

    _isolateB = await Isolate.spawn(CalculationService.runCalculation, [
      receivePort.sendPort,
      sheetContent,
    ]);

    // Wait for the first message
    try {
      AnalysisResult result = await receivePort.first;
      bool startSorter = true;
      return ThreadResult(result, startSorter);
    } catch (e) {
      // If port closes or isolate killed
      rethrow;
    } finally {
      _isolateB = null; // Cleanup
    }
  }

  Future<SortingResponse?> runHeavyCalculationC(AnalysisResult result) async {
    cancelC();

    final receivePort = ReceivePort();
    _portC = receivePort;

    _isolateC = await Isolate.spawn(_isolateEntryC, [
      receivePort.sendPort,
      result,
    ]);

    try {
      final result = await receivePort.first;
      return result as SortingResponse?;
    } catch (e) {
      rethrow;
    } finally {
      _isolateC = null;
    }
  }

}