import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Realtime Shared Table',
      home: TablePage(),
    );
  }
}

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  final CollectionReference _deltas =
      FirebaseFirestore.instance.collection('deltas');

  final int rows = 5;
  final int cols = 5;
  late List<List<String>> _table;

  @override
  void initState() {
    super.initState();
    _table = List.generate(rows, (_) => List.generate(cols, (_) => ''));
    _listenForDeltas();
  }

  /// Listen for delta messages from Firestore
  void _listenForDeltas() {
    print('🔄 [Cloud] Subscribing to Firestore delta stream...');
    _deltas.orderBy('timestamp', descending: false).snapshots().listen(
      (snapshot) {
        for (var docChange in snapshot.docChanges) {
          if (docChange.type == DocumentChangeType.added) {
            final data = docChange.doc.data() as Map<String, dynamic>?;
            if (data == null) continue;
            final int row = data['row'];
            final int col = data['col'];
            final String value = data['value'] ?? '';

            // 🪵 Log inbound data
            print(
                '⬇️ [Cloud -> Local] Received delta: row=$row, col=$col, value="$value" (doc: ${docChange.doc.id})');

            if (row >= 0 && row < rows && col >= 0 && col < cols) {
              setState(() {
                _table[row][col] = value;
              });
            }
          }
        }
      },
      onError: (error) {
        print('❌ [Cloud] Firestore stream error: $error');
      },
      onDone: () {
        print('ℹ️ [Cloud] Firestore stream closed.');
      },
    );
  }

  /// Send a delta message to Firestore
  Future<void> _sendDelta(int row, int col, String value) async {
    final delta = {
      'row': row,
      'col': col,
      'value': value,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      print('⬆️ [Local -> Cloud] Sending delta: $delta');
      await _deltas.add(delta);
      print('✅ [Cloud] Delta successfully sent.');
    } catch (e) {
      print('❌ [Cloud] Failed to send delta: $e');
    }
  }

  /// Prompt the user to edit a cell
  void _editCell(int row, int col) async {
    final controller = TextEditingController(text: _table[row][col]);
    final newValue = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit cell [$row, $col]'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter text',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newValue != null && newValue != _table[row][col]) {
      setState(() => _table[row][col] = newValue);
      await _sendDelta(row, col, newValue);
    }
  }

  void _clearLocalTable() {
    setState(() {
      _table = List.generate(rows, (_) => List.generate(cols, (_) => ''));
    });
    print('🧹 [Local] Cleared local table (no cloud action).');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Realtime Shared Table')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: rows * cols,
          itemBuilder: (context, index) {
            final row = index ~/ cols;
            final col = index % cols;
            return GestureDetector(
              onTap: () => _editCell(row, col),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.white,
                ),
                child: Text(
                  _table[row][col],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearLocalTable,
        tooltip: 'Clear local table (does not affect others)',
        child: const Icon(Icons.clear),
      ),
    );
  }
}
