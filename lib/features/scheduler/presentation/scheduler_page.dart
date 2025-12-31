import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/widgets/navigation_dropdown.dart';

class EyesHealthPage extends StatefulWidget {
  const EyesHealthPage({super.key});

  @override
  State<EyesHealthPage> createState() => _EyesHealthPageState();
}

class _EyesHealthPageState extends State<EyesHealthPage> {
  Timer? _mainTimer;
  int _secondsElapsed = 0;
  bool _isTracking = false;

  @override
  void dispose() {
    _mainTimer?.cancel();
    super.dispose();
  }

  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;
    });

    if (_isTracking) {
      // Start the timer: ticks every second
      _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _secondsElapsed++;
        });
        _checkIntervals();
      });
    } else {
      _mainTimer?.cancel();
      _secondsElapsed = 0;
    }
  }

  void _checkIntervals() {
    // 2 Hours = 7200 seconds
    if (_secondsElapsed > 0 && _secondsElapsed % 7200 == 0) {
      _showAlert("Deep Rest Needed", "You've been working for 2 hours. Take a 15-minute break.");
      return; 
    }

    // 1 Hour = 3600 seconds
    // We check if it is NOT a 2-hour mark (7200 % 3600 is also 0)
    if (_secondsElapsed > 0 && _secondsElapsed % 3600 == 0) {
      _showAlert("Hourly Break", "You've been working for an hour. Take a 5-minute pause.");
      return;
    }

    // 20 Minutes = 1200 seconds
    // Check if it's not colliding with the hour marks
    if (_secondsElapsed > 0 && _secondsElapsed % 1200 == 0) {
      _triggerEyeExercise();
    }
  }

  // Logic for the 20-20-20 rule
  void _triggerEyeExercise() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text("Eye Health"),
        content: Text("Close your eyes tightly for 20 seconds."),
      ),
    );

    // Wait 20 seconds, then tell user to open eyes
    Future.delayed(const Duration(seconds: 20), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // Close the "Close eyes" dialog
        _showAlert("Eye Health", "You can open your eyes now!");
      }
    });
  }

  Future<void> _showAlert(String title, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavigationDropdown(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.remove_red_eye, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 20),
            const Text('Eye Health Tracker', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              _formatTime(_secondsElapsed),
              style: const TextStyle(fontSize: 48, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _toggleTracking,
              icon: Icon(_isTracking ? Icons.pause : Icons.play_arrow),
              label: Text(_isTracking ? "Stop Tracking" : "Start Tracking"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                "• Every 20 mins: Close eyes (20s)\n• Every 1 hour: 5 min pause\n• Every 2 hours: 15 min pause",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}