import 'package:flutter/material.dart';
import 'package:trying_flutter/shared/widgets/navigation_dropdown.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: NavigationDropdown(),
      body: Center(
        child: Text('Welcome to the Home Page!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}