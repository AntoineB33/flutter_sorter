import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your pages
import 'home_page.dart'; 
import 'settings_page.dart'; 
import 'profile_page.dart';

// --- Route Keys ---
const String homeRoute = '/home';
const String settingsRoute = '/settings';
const String profileRoute = '/profile';
const String initialRouteKey = 'lastOpenedRoute';

// Map of page names to their route string (for the Dropdown)
final Map<String, String> pageRoutes = {
  'Home Page': homeRoute,
  'Settings': settingsRoute,
  'Profile': profileRoute,
};

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation Demo',
      // Define all your named routes
      routes: {
        homeRoute: (context) => const HomePage(),
        settingsRoute: (context) => const SettingsPage(),
        profileRoute: (context) => const ProfilePage(),
      },
      // The initial route will be determined asynchronously
      home: const InitialRouteLoader(),
    );
  }
}




class InitialRouteLoader extends StatefulWidget {
  const InitialRouteLoader({super.key});

  @override
  InitialRouteLoaderState createState() => InitialRouteLoaderState();
}

class InitialRouteLoaderState extends State<InitialRouteLoader> {
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    _loadLastRoute();
  }

  // Function to load the last route from SharedPreferences
  Future<void> _loadLastRoute() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Default to 'homeRoute' if no route is saved
    final String lastRoute = prefs.getString(initialRouteKey) ?? homeRoute;
    setState(() {
      _initialRoute = lastRoute;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialRoute == null) {
      // Show a loading indicator while fetching the route
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      // Once loaded, navigate to the correct page
      // This uses a Navigator.popAndPushNamed to immediately jump to the page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Replace the current route (this loader) with the actual page
        Navigator.of(context).pushReplacementNamed(_initialRoute!);
      });
      // Returning an empty container while the navigation happens
      return Container();
    }
  }
}

// Function to save the current route
Future<void> saveCurrentRoute(String routeName) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(initialRouteKey, routeName);
}





















class NavigationDropdown extends StatefulWidget implements PreferredSizeWidget {
  const NavigationDropdown({super.key});

  @override
  NavigationDropdownState createState() => NavigationDropdownState();
  
  // Required for the PreferredSizeWidget implementation in AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class NavigationDropdownState extends State<NavigationDropdown> {
  // Get the current route dynamically or default to homeRoute
  String? _currentRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the current active route from the modal route settings
    _currentRoute = ModalRoute.of(context)?.settings.name ?? homeRoute;
  }

  @override
  Widget build(BuildContext context) {
    // Find the current page name based on the route for the dropdown display
    String? currentName = pageRoutes.entries
        .firstWhere(
          (entry) => entry.value == _currentRoute,
          orElse: () => pageRoutes.entries.first, // Default entry
        )
        .key;

    return AppBar(
      title: DropdownButton<String>(
        value: currentName,
        icon: const Icon(Icons.arrow_downward, color: Colors.white),
        elevation: 16,
        dropdownColor: Theme.of(context).primaryColor,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        onChanged: (String? newName) {
          if (newName != null) {
            final newRoute = pageRoutes[newName]!;
            // 1. Navigate to the new page, replacing the current one
            Navigator.of(context).pushReplacementNamed(newRoute);
            // 2. Save the new route as the last-opened
            saveCurrentRoute(newRoute);
          }
        },
        items: pageRoutes.keys.map<DropdownMenuItem<String>>((String name) {
          return DropdownMenuItem<String>(
            value: name,
            child: Text(name),
          );
        }).toList(),
      ),
    );
  }
}