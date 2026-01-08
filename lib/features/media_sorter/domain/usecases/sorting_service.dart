import 'dart:convert';
import 'package:http/http.dart' as http;

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
  // NOTE: If using Android Emulator, use '10.0.2.2'. 
  // If on real device, use your PC's local IP (e.g., '192.168.1.x').
  // If iOS Simulator, use 'localhost'.
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<List<int>?> solveSorting(int n, Map<int, List<SortingRule>> rules) async {
    final url = Uri.parse('$baseUrl/solve');

    // Convert integer keys to strings for JSON
    final rulesJson = rules.map((key, value) => 
      MapEntry(key.toString(), value.map((e) => e.toJson()).toList())
    );

    final body = jsonEncode({
      'n': n,
      'rules': rulesJson,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return List<int>.from(data['solution']);
        }
      }
      print('Server Error: ${response.body}');
      return null;
    } catch (e) {
      print('Connection Error: $e');
      return null;
    }
  }
}