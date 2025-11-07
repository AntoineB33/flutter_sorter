import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final JavascriptRuntime jsRuntime = getJavascriptRuntime();
  String result = '';

  Future<void> callJsFunction() async {
    // Load JS file content
    final jsCode = await rootBundle.loadString('assets/js/calc.js');
    jsRuntime.evaluate(jsCode); // Load JS code into runtime

    // Call the function
    final jsResult = jsRuntime.evaluate("addTen(32)");
    setState(() {
      result = jsResult.stringResult ?? 'No result';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter JS Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter + JS Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: callJsFunction,
                child: const Text('Run JS Function'),
              ),
              const SizedBox(height: 20),
              Text('Result: $result'),
            ],
          ),
        ),
      ),
    );
  }
}
