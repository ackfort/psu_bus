import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // สีพื้นหลังเข้มขึ้นเล็กน้อย
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBar(
        onDestinationSelected: onTap,
        selectedIndex: currentIndex,
        backgroundColor: Colors.transparent, // ใช้สีพื้นหลังจาก Container แทน
        indicatorColor: theme.colorScheme.primary,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        surfaceTintColor: Colors.transparent,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.route, color: theme.colorScheme.onPrimary),
            icon: Icon(Icons.route_outlined, color: theme.colorScheme.onSurface.withOpacity(0.7)),
            label: 'เส้นทาง',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.map, color: theme.colorScheme.onPrimary),
            icon: Icon(Icons.map_outlined, color: theme.colorScheme.onSurface.withOpacity(0.7)),
            label: 'แผนที่',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.people, color: theme.colorScheme.onPrimary),
            icon: Icon(Icons.people_outline, color: theme.colorScheme.onSurface.withOpacity(0.7)),
            label: 'ผู้โดยสาร',
          ),
        ],
      ),
    );
  }
}