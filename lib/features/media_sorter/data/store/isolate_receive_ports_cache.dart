
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

  
  void addIsolatePortIfNecessary(String sheetId) {
    _isolatePorts[sheetId] ??= IsolateReceivePorts();
  }

  void initPortC(String sheetId) {
    _isolatePorts[sheetId]!._portC = ReceivePort();
  }

  SendPort getSendPortC(String sheetId) {
    return _isolatePorts[sheetId]!._portC!.sendPort;
  }

   getIsolatePort(String sheetId) {
    return _isolatePorts[sheetId]!._portC!;
  }

  void setIsolateC(String sheetId, Isolate isolate) {
    _isolatePorts[sheetId]!._isolateC = isolate;
  }
}