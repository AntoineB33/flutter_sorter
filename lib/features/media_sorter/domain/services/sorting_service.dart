import 'dart:convert';
import 'dart:io'; // Import dart:io
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'; // Import path_provider

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
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<List<int>?> solveSorting(int n, Map<int, List<SortingRule>> rules) async {
    final url = Uri.parse('$baseUrl/solve');

    final rulesJson = rules.map((key, value) => 
      MapEntry(key.toString(), value.map((e) => e.toJson()).toList())
    );

    final body = jsonEncode({
      'n': n,
      'rules': rulesJson,
    });

    // --- DEBUG: Save body to file ---
    // await _saveDebugFile(body); 
    // --------------------------------

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
      debugPrint('Server Error: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Connection Error: $e');
      return null;
    }
  }

  /// Helper to save the JSON string to a file for Python debugging
  // ignore: unused_element
  Future<void> _saveDebugFile(String jsonContent) async {
    try {
      // 1. Get a valid directory (Works on Android/iOS/Desktop)
      final directory = await getApplicationDocumentsDirectory();
      
      // 2. Define the path
      final path = '${directory.path}/debug_payload.json';
      final file = File(path);

      // 3. Write the file
      await file.writeAsString(jsonContent);

      // 4. Print location so you can find it
      debugPrint('>>> DEBUG JSON SAVED AT: $path');
    } catch (e) {
      debugPrint('>>> FAILED TO SAVE DEBUG JSON: $e');
    }
  }
}