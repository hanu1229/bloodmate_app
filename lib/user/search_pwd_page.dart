import 'package:flutter/material.dart';

class SearchPwdPage extends StatefulWidget {
  const SearchPwdPage({super.key});

  @override
  State<SearchPwdPage> createState() => _SearchPwdPageState();
}

class _SearchPwdPageState extends State<SearchPwdPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        title : Text("비밀번호 찾기"),
        backgroundColor : Colors.white,
      ),
      body : Container(
        color : Colors.white,
        width : double.infinity,
        child : Column(
          children : [
            Text("비밀번호 찾기 페이지"),
          ],
        ),
      ),
    );
  }
}
