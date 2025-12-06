import 'package:flutter/material.dart';
import '../../core/constants/route_constants.dart';
import '../../core/services/storage_service.dart';

class NavigationDropdown extends StatefulWidget implements PreferredSizeWidget {
  const NavigationDropdown({super.key});

  @override
  NavigationDropdownState createState() => NavigationDropdownState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class NavigationDropdownState extends State<NavigationDropdown> {
  String? _currentRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get current route name
    _currentRoute = ModalRoute.of(context)?.settings.name ?? RouteConstants.home;
  }

  @override
  Widget build(BuildContext context) {
    // Find display name (Key) based on route (Value)
    String currentName = RouteConstants.pageRoutes.entries
        .firstWhere(
          (entry) => entry.value == _currentRoute,
          orElse: () => RouteConstants.pageRoutes.entries.first,
        )
        .key;

    return AppBar(
      title: DropdownButton<String>(
        value: currentName,
        icon: const Icon(Icons.arrow_downward, color: Colors.white),
        elevation: 16,
        dropdownColor: Theme.of(context).primaryColor,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        underline: Container(), // Remove the default underline
        onChanged: (String? newName) {
          if (newName != null) {
            final newRoute = RouteConstants.pageRoutes[newName]!;
            
            // 1. Navigate
            Navigator.of(context).pushReplacementNamed(newRoute);
            
            // 2. Persist
            StorageService.saveLastRoute(newRoute);
          }
        },
        items: RouteConstants.pageRoutes.keys.map<DropdownMenuItem<String>>((String name) {
          return DropdownMenuItem<String>(
            value: name,
            child: Text(name),
          );
        }).toList(),
      ),
    );
  }
}