import 'package:flutter/material.dart';

class SearchIdPage extends StatefulWidget {
  const SearchIdPage({super.key});

  @override
  State<SearchIdPage> createState() => _SearchIdPageState();
}

class _SearchIdPageState extends State<SearchIdPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        title : Text("아이디 찾기"),
        backgroundColor : Colors.white,
      ),
      body : Container(
        color : Colors.white,
        width : double.infinity,
        child : Column(
          children : [
            Text("아이디 찾기 페이지"),
          ],
        ),
      ),
    );;
  }
}
