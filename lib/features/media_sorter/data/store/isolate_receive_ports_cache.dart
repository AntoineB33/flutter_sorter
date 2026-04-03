import 'dart:isolate';

class IsolateReceivePorts {
  Isolate? _isolateB;
  Isolate? _isolateC;

  // We use Completers to handle the "result" promise which we might need to
  // abandon if the isolate is killed.
  ReceivePort? _portB;
  ReceivePort? _portC;
}

class IsolateReceivePortsCache {
  final Map<int, IsolateReceivePorts> _isolatePorts = {};

  void cancelB(int sheetId) {
    if (_isolatePorts[sheetId]!._isolateB != null) {
      // Kill the isolate immediately
      _isolatePorts[sheetId]!._isolateB!.kill(priority: Isolate.immediate);
      _isolatePorts[sheetId]!._isolateB = null;
    }
    // Close the ReceivePort to prevent memory leaks
    if (_isolatePorts[sheetId]!._portB != null) {
      _isolatePorts[sheetId]!._portB!.close();
      _isolatePorts[sheetId]!._portB = null;
    }
  }

  void cancelC(int sheetId) {
    _isolatePorts[sheetId] ??= IsolateReceivePorts();
    if (_isolatePorts[sheetId]!._isolateC != null) {
      // Kill the isolate immediately
      _isolatePorts[sheetId]!._isolateC!.kill(priority: Isolate.immediate);
      _isolatePorts[sheetId]!._isolateC = null;
    }
    // Close the ReceivePort to prevent memory leaks
    if (_isolatePorts[sheetId]!._portC != null) {
      _isolatePorts[sheetId]!._portC!.close();
      _isolatePorts[sheetId]!._portC = null;
    }
  }

  void initPortB(int sheetId) {
    _isolatePorts[sheetId] ??= IsolateReceivePorts();
    _isolatePorts[sheetId]!._portB = ReceivePort();
  }

  void initPortC(int sheetId) {
    _isolatePorts[sheetId] ??= IsolateReceivePorts();
    _isolatePorts[sheetId]!._portC = ReceivePort();
  }

  SendPort getSendPortC(int sheetId) {
    return _isolatePorts[sheetId]!._portC!.sendPort;
  }

  ReceivePort getReceivePortB(int sheetId) {
    return _isolatePorts[sheetId]!._portB!;
  }

  ReceivePort getReceivePortC(int sheetId) {
    return _isolatePorts[sheetId]!._portC!;
  }

  void setIsolateB(int sheetId, Isolate? isolate) {
    _isolatePorts[sheetId]!._isolateB = isolate;
  }

  void setIsolateC(int sheetId, Isolate? isolate) {
    _isolatePorts[sheetId]!._isolateC = isolate;
  }
}
