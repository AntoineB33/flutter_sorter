import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message received: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _token;
  String _message = "No messages yet.";

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _initFCM() async {
    // Request permissions (required for iOS/web)
    await _messaging.requestPermission();

    // Get this device's FCM token
    _token = await _messaging.getToken();
    print('Device Token: $_token');

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        _message = message.notification?.body ?? "Received a message!";
      });
    });
  }

  Future<void> _sendMessage() async {
    if (_token == null) return;

    const serverKey = 'YOUR_FIREBASE_SERVER_KEY_HERE'; // Get from Firebase > Project Settings > Cloud Messaging

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode({
        'to': _token, // for testing, send to yourself — replace with another token to send elsewhere
        'notification': {
          'title': 'Hello from Flutter!',
          'body': 'This is a test message!',
        },
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _message = "Message sent!";
      });
    } else {
      setState(() {
        _message = "Failed to send message: ${response.body}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Messaging Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Firebase Messaging Example')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Your token:\n${_token ?? "Loading..."}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Text('Send Message'),
                ),
                const SizedBox(height: 20),
                Text('Last message: $_message'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
