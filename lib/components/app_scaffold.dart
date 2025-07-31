import 'package:flutter/material.dart';
import 'custom_navigation_bar.dart';
import '../screens/route_map_screen.dart';
import '../screens/map_screen.dart';
import '../screens/passenger_density_screen.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int currentPageIndex = 0;

  final List<Widget> _pages = [
    RouteMapScreen(),
    MapScreen(),
    PassengerDensityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[currentPageIndex],
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: currentPageIndex,
        onTap: (index) => setState(() => currentPageIndex = index),
      ),
    );
  }
}