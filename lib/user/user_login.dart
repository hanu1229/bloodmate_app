import 'package:flutter/material.dart';

class UserLogin extends StatefulWidget {

  /// <b>로그인 페이지</b>
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(),
      body : Container(
        width : double.infinity,
        child: Column(
          mainAxisAlignment : MainAxisAlignment.center,
          crossAxisAlignment : CrossAxisAlignment.center,
          children : [
            Text("로그인 페이지"),
          ],
        ),
      ),
    );
  }
}
