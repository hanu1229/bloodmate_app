import 'package:bloodmate_app/main_layout.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BloodMate());
}

class BloodMate extends StatelessWidget {
  const BloodMate({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner : false,
      theme : ThemeData(
        useMaterial3 : true,
        // body 스크롤 시 AppBar 색상 변경 되는 현상 방지
        appBarTheme : AppBarTheme(
          scrolledUnderElevation : 0,
          surfaceTintColor : Colors.transparent,
          elevation : 0,
        ),
      ),
      title : "블러드메이트",
      home : MainLayout()
    );
  }

}