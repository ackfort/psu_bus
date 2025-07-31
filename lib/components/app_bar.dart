import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onSettingsPressed;

  const CustomAppBar({
    super.key,
    this.onNotificationPressed,
    this.onSettingsPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_bus, size: 30, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 12),
          Text(
            'PSU Bus Tracker',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.primary,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications, color: theme.colorScheme.onPrimary),
          onPressed: onNotificationPressed,
        ),
        IconButton(
          icon: Icon(Icons.settings, color: theme.colorScheme.onPrimary),
          onPressed: onSettingsPressed,
        ),
      ],
    );
  }
}