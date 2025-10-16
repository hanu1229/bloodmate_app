import 'package:flutter/material.dart';

class Hba1cPage extends StatefulWidget {
  /// <b>당화혈색소 페이지</b>
  const Hba1cPage({super.key});

  @override
  State<Hba1cPage> createState() => _Hba1cPageState();

}

class _Hba1cPageState extends State<Hba1cPage> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width : double.infinity,
      child: Column(
        mainAxisAlignment : MainAxisAlignment.center,
        crossAxisAlignment : CrossAxisAlignment.center,
        children : [
          Text("당화혈색소 페이지"),
        ],
      ),
    );
  }

}