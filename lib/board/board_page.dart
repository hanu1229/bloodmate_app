import 'package:flutter/material.dart';

class BoardPage extends StatefulWidget {

  /// <b>게시판 페이지</b>
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();

}

class _BoardPageState extends State<BoardPage> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width : double.infinity,
      child: Column(
        mainAxisAlignment : MainAxisAlignment.center,
        crossAxisAlignment : CrossAxisAlignment.center,
        children : [
          Text("게시판 페이지"),
        ],
      ),
    );
  }

}