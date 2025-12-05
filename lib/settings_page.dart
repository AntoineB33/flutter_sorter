import 'package:flutter/material.dart';
import 'main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use the custom dropdown as the AppBar
      appBar: const NavigationDropdown(), 
      body: const Center(
        child: Text('Welcome to the Settings Page!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
// Do the same for SettingsPage and ProfilePage.