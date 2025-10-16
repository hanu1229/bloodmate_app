import 'package:flutter/material.dart';

class SugarPage extends StatefulWidget {
  
  /// <b>혈당 페이지</b>
  const SugarPage({super.key});

  @override
  State<SugarPage> createState() => _SugarPageState();
}

class _SugarPageState extends State<SugarPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width : double.infinity,
      child: Column(
        mainAxisAlignment : MainAxisAlignment.center,
        crossAxisAlignment : CrossAxisAlignment.center,
        children : [
          Text("혈당 페이지"),
        ],
      ),
    );
  }
}
