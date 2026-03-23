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
  final Map<String, IsolateReceivePorts> _isolatePorts = {};

  void cancelB(String sheetId) {
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

  void cancelC(String sheetId) {
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

  void addIsolatePortIfNecessary(String sheetId) {
    _isolatePorts[sheetId] ??= IsolateReceivePorts();
  }

  void initPortB(String sheetId) {
    _isolatePorts[sheetId]!._portB = ReceivePort();
  }

  void initPortC(String sheetId) {
    _isolatePorts[sheetId]!._portC = ReceivePort();
  }

  SendPort getSendPortC(String sheetId) {
    return _isolatePorts[sheetId]!._portC!.sendPort;
  }

  ReceivePort getReceivePortB(String sheetId) {
    return _isolatePorts[sheetId]!._portB!;
  }

  ReceivePort getReceivePortC(String sheetId) {
    return _isolatePorts[sheetId]!._portC!;
  }

  void setIsolateB(String sheetId, Isolate? isolate) {
    _isolatePorts[sheetId]!._isolateB = isolate;
  }

  void setIsolateC(String sheetId, Isolate? isolate) {
    _isolatePorts[sheetId]!._isolateC = isolate;
  }
}
