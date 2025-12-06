import 'package:flutter/material.dart';
import '../../../../shared/widgets/navigation_dropdown.dart';

class MediaSorterPage extends StatelessWidget {
  const MediaSorterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: NavigationDropdown(),
      body: Center(child: Text('Media Sorter Page', style: TextStyle(fontSize: 24))),
    );
  }
}
