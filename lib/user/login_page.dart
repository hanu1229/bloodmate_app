import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {

  /// <b>로그인 페이지</b>
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  Dio dio = Dio();

  bool _visibility = true;
  bool _loginfail = false;

  TextEditingController idController = TextEditingController();
  TextEditingController pwdController = TextEditingController();

  Future<void> onLogin(BuildContext context) async {
    String id = idController.text;
    String pwd = pwdController.text;
    print("id : $id | pwd : $pwd");
    try {
      final response = await dio.post("${ServerDomain.domain}/user/login", data : {"userLoginId" : id, "userPassword" : pwd});
      if(response.statusCode == 200) {
        SharedPreferences sp = await SharedPreferences.getInstance();
        await sp.setString("token", response.data);
        print(sp.getString("token"));
        Navigator.pop(context);
      }
    } catch(e) {
      setState(() {
        _loginfail = true;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        backgroundColor : Colors.white,
        leading : IconButton(icon : Icon(Icons.arrow_back, color : AppColors.mainColor), onPressed : () { Navigator.pop(context); }),
      ),
      body : SafeArea(
        child: Container(
          padding : const EdgeInsets.symmetric(vertical : 16.0, horizontal : 32.0),
          color : Colors.white,
          width : double.infinity,
          child: Column(
            children : [
              // 메인 텍스트
              Text("블러드 메이트", style : TextStyle(fontSize : 32, fontWeight : FontWeight.bold, color : AppColors.mainTextColor)),
              SizedBox(height : 16.0),
              // 아이디 텍스트 필드
              TextField(
                controller : idController,
                decoration : InputDecoration(
                  border : OutlineInputBorder(
                  ),
                  label : Text("아이디"),
                ),
              ),
              SizedBox(height : 16.0),
              // 비밀번호 텍스트 필드
              TextField(
                controller : pwdController,
                obscureText : _visibility,
                decoration : InputDecoration(
                  border : OutlineInputBorder(),
                  label : Text("비밀번호"),
                  suffixIcon : IconButton(
                    icon : Icon(_visibility ? Icons.visibility : Icons.visibility_off, color : AppColors.mainColor),
                    onPressed : () {
                      setState(() {
                        _visibility = !_visibility;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height : 16.0),
              // 로그인 버튼
              SizedBox(
                width : double.infinity,
                child: ElevatedButton(
                  onPressed : () { onLogin(context); },
                  style : ElevatedButton.styleFrom(
                    backgroundColor : AppColors.mainColor,
                    shape : RoundedRectangleBorder(
                      borderRadius : BorderRadius.circular(4.0),
                    ),
                  ),
                  child : Text("로그인", style : TextStyle(color : Colors.white)),
                ),
              ),
              SizedBox(height : 16.0),
              // 로그인 실패 텍스트
              SizedBox(
                  child : Text(
                      _loginfail ? "로그인 실패" : "",
                      style : TextStyle(
                          color : Colors.red,
                          fontSize : 16,
                          fontWeight : FontWeight.bold,
                      ),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
