import 'package:flutter/material.dart';
import 'core/constants/route_constants.dart';
import 'features/food_plan/presentation/pages/food_plan_page.dart';
import 'features/media_sorter/presentation/pages/media_sorter_page.dart';
import 'features/scheduler/presentation/scheduler_page.dart';

class MyApp extends StatelessWidget {
  final String initialRoute;

  // We pass the initial route into the App constructor
  // so we don't need a loading spinner widget
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: initialRoute,
      routes: {
        RouteConstants.home: (context) => const FoodPlanPage(),
        RouteConstants.scheduler: (context) => const EyesHealthPage(),
        RouteConstants.profile: (context) => const MediaSorterPage(),
      },
    );
  }
}
