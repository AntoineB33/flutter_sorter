import 'package:shared_preferences/shared_preferences.dart';
import 'package:trying_flutter/core/constants/route_constants.dart';

class StorageService {
  // Save the current route
  static Future<void> saveLastRoute(String routeName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(RouteConstants.initialRouteKey, routeName);
  }

  // Get the last route (returns Home by default)
  static Future<String> getLastRoute() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(RouteConstants.initialRouteKey) ?? RouteConstants.home;
  }
}