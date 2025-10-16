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
      title: LayoutBuilder(
        builder: (context, constraints) {
          // ตรวจสอบความกว้างที่ใช้ได้
          final availableWidth =
              constraints.maxWidth - 120; // ลบพื้นที่ปุ่ม action

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.directions_bus,
                size: 30,
                color: theme.colorScheme.onPrimary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'PSU Passenger Counting System',
                  style: TextStyle(
                    fontSize: _calculateFontSize(availableWidth),
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          );
        },
      ),
      backgroundColor: theme.colorScheme.primary,
    );
  }

  // คำนวณขนาดฟอนต์ตามความกว้างที่ใช้ได้
  double _calculateFontSize(double availableWidth) {
    const fullText = 'PSU Passenger Counting System';
    const baseFontSize = 20.0;
    const minFontSize = 14.0;

    // คำนวณความยาวข้อความโดยประมาณ
    final textWidth = fullText.length * baseFontSize * 0.6;

    if (textWidth > availableWidth) {
      // ปรับขนาดฟอนต์ตามสัดส่วน
      final adjustedSize = availableWidth / fullText.length / 0.6;
      return adjustedSize.clamp(minFontSize, baseFontSize);
    }
    return baseFontSize;
  }
}
