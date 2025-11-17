import 'dart:async';



class FunctionQueue {
  final List<_QueueItem> _queue = [];
  bool _running = false;

  Future<T> enqueue<T>(Future<T> Function(dynamic args) fn, dynamic args) {
    final completer = Completer<T>();

    // If queue has more than 1 item, drop them like your JS version
    if (_queue.length == 1) {
      _queue.clear();
    }

    _queue.add(_QueueItem(fn, args, completer));
    _runNext();

    return completer.future;
  }

  void _runNext() async {
    if (_running || _queue.isEmpty) return;

    _running = true;
    final item = _queue.removeAt(0);

    try {
      final result = await item.fn(item.args);
      item.completer.complete(result);
    } catch (e, st) {
      item.completer.completeError(e, st);
    } finally {
      _running = false;
      _runNext();
    }
  }
}

class _QueueItem<T> {
  final Future<T> Function(dynamic args) fn;
  final dynamic args;
  final Completer<T> completer;

  _QueueItem(this.fn, this.args, this.completer);
}


final queue = FunctionQueue();