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
      title : "블러드메이트",
      home : MainLayout()
    );
  }

}