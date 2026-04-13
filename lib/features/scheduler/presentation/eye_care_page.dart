import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class EyeCarePage extends StatefulWidget {
  const EyeCarePage({super.key});

  @override
  State<EyeCarePage> createState() => _EyeCarePageState();
}

class _EyeCarePageState extends State<EyeCarePage> with WidgetsBindingObserver {
  // Configurable durations
  static const int workDurationSeconds = 20 * 60; // 20 minutes
  static const int restDurationSeconds = 20; // 20 seconds

  // State variables
  int _secondsRemaining = workDurationSeconds;
  Timer? _timer;
  bool _isResting = false;
  DateTime? _pausedTime;

  // Plugins
  final FlutterTts _flutterTts = FlutterTts();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPlugins();
    _startTimer();
  }

  Future<void> _initPlugins() async {
    // Setup TTS
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);

    // Setup Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _notificationsPlugin.initialize(initializationSettings);
    
    // Request permissions for Android 13+ and iOS
    _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0 && !_isResting) {
        setState(() {
          _secondsRemaining--;
        });
      } else if (_secondsRemaining <= 0 && !_isResting) {
        _triggerRestPhase();
      }
    });
  }

  Future<void> _triggerRestPhase() async {
    setState(() {
      _isResting = true;
    });

    _showNotification("Eye Care Reminder", "Look away from the screen!");
    await _flutterTts.speak("Look away");

    // Wait for 20 seconds
    await Future.delayed(const Duration(seconds: restDurationSeconds));

    await _flutterTts.speak("You can continue");

    // Reset and resume
    setState(() {
      _secondsRemaining = workDurationSeconds;
      _isResting = false;
    });
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'eye_care_channel',
      'Eye Care Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(0, title, body, platformDetails);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // User locked the device or minimized the app
      _pausedTime = DateTime.now();
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      // User returned to the app
      if (_pausedTime != null) {
        final durationAway = DateTime.now().difference(_pausedTime!);
        
        setState(() {
          if (durationAway.inSeconds >= restDurationSeconds) {
            // Away for more than 20 seconds: Reset the 20-minute timer entirely
            _secondsRemaining = workDurationSeconds;
            _isResting = false;
          } else {
            // Away for less than 20 seconds: Subtract the time away from the remaining time
            _secondsRemaining -= durationAway.inSeconds;
            if (_secondsRemaining < 0) _secondsRemaining = 0;
          }
        });
      }
      _startTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // Helper to format MM:SS
  String get _formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Eye Care 20-20-20")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isResting ? "Rest your eyes!" : "Time until next break:",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              _isResting ? "00:00" : _formattedTime,
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 40),
            if (_isResting)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _secondsRemaining = workDurationSeconds;
                  });
                },
                child: const Text("Reset Timer"),
              )
          ],
        ),
      ),
    );
  }
}