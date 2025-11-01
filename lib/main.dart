import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:flutter/services.dart'; // for PhysicalKeyboardKey

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Must initialize the manager before registering hotkeys
  await hotKeyManager.unregisterAll();

  // ✅ Define a system-wide hotkey: Ctrl + Shift + H
  HotKey hotKey = HotKey(
    key: PhysicalKeyboardKey.keyH, // <-- required named parameter
    modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
    scope: HotKeyScope.system, // system-wide (works even when unfocused)
  );

  // ✅ Register the hotkey
  await hotKeyManager.register(
    hotKey,
    keyDownHandler: (hotKey) {
      debugPrint("🎯 Global hotkey pressed!");
    },
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text("Global Hotkey Example")),
          body: const Center(
            child: Text("Press Ctrl + Shift + H (even when app not focused)"),
          ),
        ),
      );
}
