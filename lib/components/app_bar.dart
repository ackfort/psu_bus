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
  // กำหนดความสูงของ AppBar ที่ปรับปรุงแล้ว
  Size get preferredSize => const Size.fromHeight(70.0); // เพิ่มความสูงจากค่าเริ่มต้น (56.0)

  @override
  Widget build(BuildContext context) {
    // กำหนดสีตามภาพตัวอย่างที่คุณให้มา
    const customAppBarColor = Color(0xFF13396D); // สีน้ำเงินเข้ม
    const customTextColor = Colors.white; // สีข้อความหลัก
    
    // แก้ไขปัญหา 'Methods can't be invoked in constant expressions'
    // โดยการแปลง Colors.black.withOpacity(0.3) เป็น Hex Code (0x4D000000)
    const shadowColorDark = Color(0x4D000000); 

    return AppBar(
      // กำหนดสีพื้นหลัง AppBar
      backgroundColor: customAppBarColor, 
      
      // ทำให้ Title อยู่ตรงกลาง
      centerTitle: true, 
      
      // ปรับความสูงของ AppBar เพื่อเพิ่ม Padding แนวตั้ง
      toolbarHeight: 70.0, // เพิ่มความสูง/padding 
      
      title: const Text(
        'PSUBUS',
        style: TextStyle(
          fontSize: 36, // 💡 ลดขนาดตัวอักษรลง (จาก 48 เป็น 36)
          fontWeight: FontWeight.w900, 
          color: customTextColor, 
          
          // ส่วนสำหรับสร้างเอฟเฟกต์ขอบเงา (Outline/Shadow)
          shadows: [
            // เงาแรก: สร้างขอบสีเข้ม/น้ำเงินรอบข้อความ
            Shadow(
              blurRadius: 0.0, 
              color: customAppBarColor, 
              offset: Offset(2.0, 2.0), 
            ),
            Shadow(
              blurRadius: 0.0,
              color: customAppBarColor,
              offset: Offset(-2.0, -2.0), 
            ),
             Shadow(
              blurRadius: 0.0,
              color: customAppBarColor,
              offset: Offset(2.0, -2.0), 
            ),
             Shadow(
              blurRadius: 0.0,
              color: customAppBarColor,
              offset: Offset(-2.0, 2.0), 
            ),
            // เงาที่สอง: เงาสีดำเพื่อความลึก (ใช้ const Color ที่ถูกแก้ไขแล้ว)
            Shadow(
              blurRadius: 4.0, 
              color: shadowColorDark, 
              offset: Offset(4.0, 4.0), 
            ),
          ],
        ),
      ),
      
      // actions: ถูกลบออกไปแล้ว
    );
  }
}