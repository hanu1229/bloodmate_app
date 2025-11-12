import 'package:bloodmate_app/modals/CustomAlertDialog.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:bloodmate_app/user/user_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordChangePage extends StatefulWidget {

  const PasswordChangePage({super.key});

  @override
  State<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {

  Dio dio = Dio();
  final String domain = ServerDomain.domain;
  bool _visibility1 = true;
  bool _visibility2 = true;

  TextEditingController passwordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  /// 비밀번호 수정
  Future<void> changePassword() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final data = {"password" : passwordController.text, "newPassword" : newPasswordController.text};
      final response = await dio.patch("$domain/user/information/password", data : data, options : Options(headers : {"Authorization" : token}));
      if(response.statusCode == 200) {
        await showDialog(
            context : context,
            builder : (context) => CustomAlertDialog(
              context : context,
              title : "변경 성공",
              content : "비밀번호가 성공적으로 변경되었습니다.",
              isChange : true,
            )
        );
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 400) {
        print("실패??");
        await showDialog(
            context : context,
            builder : (context) => CustomAlertDialog(
              context : context,
              title : "변경 실패",
              content : "비밀번호 변경에 실패했습니다.",
              isChange : false,
            )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 키보드 픽셀 오류
      resizeToAvoidBottomInset : false,
      backgroundColor : Colors.white,
      appBar : AppBar(
        title : Text("비밀번호 수정하기"),
        backgroundColor : Colors.white,
      ),
      body : SafeArea(
        child : Container(
          padding : const EdgeInsets.symmetric(vertical : 16.0, horizontal : 16.0),
          width : double.infinity,
          child : Column(
            crossAxisAlignment : CrossAxisAlignment.start,
            children : [
              Text("현재 비밀번호", style : TextStyle(fontSize : 20)),
              SizedBox(height : 16),
              // 현재 비밀번호
              SizedBox(
                // height : 40,
                child: TextField(
                  controller : passwordController,
                  obscureText : _visibility1,
                  decoration : InputDecoration(
                    enabledBorder : OutlineInputBorder(
                        borderSide : BorderSide(color : AppColors.mainColor, width : 1)
                    ),
                    focusedBorder : OutlineInputBorder(
                        borderSide : BorderSide(color : AppColors.mainColor, width : 2)
                    ),
                    prefixIcon : Icon(Icons.key, color : AppColors.mainColor),
                    suffixIcon : IconButton(
                      onPressed : () {
                        setState(() {
                          _visibility1 = !_visibility1;
                        });
                      },
                      icon : Icon(_visibility1 ? Icons.visibility : Icons.visibility_off, color : AppColors.mainColor),
                    ),
                  ),

                ),
              ),
              SizedBox(height : 16),
              Text("변경할 비밀번호", style : TextStyle(fontSize : 20)),
              SizedBox(height : 16),
              // 변경할 비밀번호
              SizedBox(
                // height : 40,
                child: TextField(
                  controller : newPasswordController,
                  obscureText : _visibility2,
                  decoration : InputDecoration(
                    enabledBorder : OutlineInputBorder(
                        borderSide : BorderSide(color : AppColors.mainColor, width : 1)
                    ),
                    focusedBorder : OutlineInputBorder(
                        borderSide : BorderSide(color : AppColors.mainColor, width : 2)
                    ),
                    prefixIcon : Icon(Icons.key, color : AppColors.mainColor),
                    suffixIcon : IconButton(
                      onPressed : () {
                        setState(() {
                          _visibility2 = !_visibility2;
                        });
                      },
                      icon : Icon(_visibility2 ? Icons.visibility : Icons.visibility_off, color : AppColors.mainColor),
                    ),
                  ),

                ),
              ),
              SizedBox(height : 16),
              SizedBox(
                width : double.infinity,
                child : ElevatedButton(
                  style : ElevatedButton.styleFrom(
                    backgroundColor : AppColors.mainColor,
                    shape : RoundedRectangleBorder(
                      borderRadius : BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: changePassword,
                  child: Text("수정하기", style : TextStyle(color : Colors.white, fontSize : 16, fontWeight : FontWeight.bold)),
                ),
              ),
              SizedBox(height : 16),
            ],
          ),
        ),
      ),
    );
  }
}
