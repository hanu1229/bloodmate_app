import 'package:flutter/material.dart';

class PressurePage extends StatefulWidget {

  /// <b>혈압 페이지</b>
  const PressurePage({super.key});

  @override
  State<PressurePage> createState() => _PressurePageState();

}

class _PressurePageState extends State<PressurePage> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width : double.infinity,
      child: Column(
        mainAxisAlignment : MainAxisAlignment.center,
        crossAxisAlignment : CrossAxisAlignment.center,
        children : [
          Text("혈압 페이지"),
        ],
      ),
    );
  }

}