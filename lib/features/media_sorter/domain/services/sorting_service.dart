import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SortingRule {
  final int minVal;
  final int maxVal;
  final int? relativeTo;

  SortingRule({
    required this.minVal,
    required this.maxVal,
    this.relativeTo,
  });

  Map<String, dynamic> toJson() => {
        'min_val': minVal,
        'max_val': maxVal,
        'relative_to': relativeTo,
      };
}

class SortingService {
  static const String wsUrl = 'ws://127.0.0.1:8000/ws/solve';

  /// Returns a Stream of solutions. 
  /// If maximizeBetween is null, it returns one solution and closes.
  /// If maximizeBetween is set, it yields better solutions as they arrive.
  Stream<List<int>> solveSortingStream(
    int n, 
    Map<int, List<SortingRule>> rules, 
    {List<int>? maximizeBetween}
  ) async* {
    final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    final payload = jsonEncode({
      'n': n,
      'rules': rules.map((k, v) => MapEntry(k.toString(), v.map((e) => e.toJson()).toList())),
      'maximize_distance_between': maximizeBetween,
    });

    channel.sink.add(payload);

    await for (final message in channel.stream) {
      final data = jsonDecode(message);
      
      if (data['status'] == 'progress' || data['status'] == 'success') {
        yield List<int>.from(data['solution']);
      }
      
      if (data['status'] == 'finished' || data['status'] == 'failure') {
        channel.sink.close();
        break;
      }
    }
  }
}
