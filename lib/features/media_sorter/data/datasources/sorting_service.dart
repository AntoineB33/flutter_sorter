import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_response.dart';

class PythonSortingService {
  static const String wsUrl = 'ws://127.0.0.1:8000/ws/solve';

  /// Returns a Stream of SortingResponse.
  /// Set [checkNaturalOrder] to true if you want the backend to verify if 0..N is valid.
  Stream<SortingResponse> solveSortingStream(
    int n,
    Map<int, Map<int, List<SortingRule>>> rules, {
    List<List<int>>? groupsToMaximize,
    bool checkNaturalOrder = false,
  }) async* {
    final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    final payload = jsonEncode({
      'n': n,
      'rules': rules.map(
        (k, v) => MapEntry(
          k.toString(),
          v.map(
            (innerK, innerV) => MapEntry(
              innerK.toString(),
              innerV.map((e) => e.toJson()).toList(),
            ),
          ),
        ),
      ),
      'maximize_distance_between': groupsToMaximize,
      'check_natural_order': checkNaturalOrder,
    });

    channel.sink.add(payload);

    try {
      await for (final message in channel.stream) {
        final data = jsonDecode(message);

        if (data['status'] == 'progress' || data['status'] == 'success') {
          yield SortingResponse(
            sortedIds: List<int>.from(data['solution']),
            // Default to false if key is missing, though server should send it
            isNaturalOrderValid: data['is_natural_valid'] ?? false,
          );
        }

        if (data['status'] == 'finished' || data['status'] == 'failure') {
          // If it failed but we still want the natural order check result (edge case),
          // you might want to handle 'failure' specifically, but usually 'failure'
          // means no solution found for the constraints.
          await channel.sink.close();
          break;
        }
      }
    } catch (e) {
      // Ensure channel closes on error
      await channel.sink.close();
      rethrow;
    }
  }
}
