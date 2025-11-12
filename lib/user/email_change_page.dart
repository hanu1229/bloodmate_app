import 'package:bloodmate_app/modals/CustomAlertDialog.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:bloodmate_app/user/user_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailChangePage extends StatefulWidget {

  final String email;

  const EmailChangePage({super.key, required this.email});

  @override
  State<EmailChangePage> createState() => _EmailChangePageState();
}

class _EmailChangePageState extends State<EmailChangePage> {

  Dio dio = Dio();
  final String domain = ServerDomain.domain;
  bool _visibility = true;

  TextEditingController oldEmailController = TextEditingController();
  TextEditingController newEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      oldEmailController.text = widget.email;
    });
  }

  /// 이메일 수정
  Future<void> changeEmail() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final data = {"email" : oldEmailController.text, "newEmail" : newEmailController.text, "password" : passwordController.text};
      final response = await dio.patch("$domain/user/information/email", data : data, options : Options(headers : {"Authorization" : token}));
      if(response.statusCode == 200) {
        await showDialog(
            context : context,
            builder : (context) => CustomAlertDialog(
              context : context,
              title : "변경 성공",
              content : "이메일이 성공적으로 변경되었습니다.",
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
              content : "이메일 변경에 실패했습니다.",
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
        title : Text("이메일 수정하기"),
        backgroundColor : Colors.white,
      ),
      body : SafeArea(
        child : Container(
          padding : const EdgeInsets.symmetric(vertical : 16.0, horizontal : 16.0),
          width : double.infinity,
          child : Column(
            crossAxisAlignment : CrossAxisAlignment.start,
            children : [
              Text("현재 이메일", style : TextStyle(fontSize : 20)),
              SizedBox(height : 16),
              // 현재 이메일
              SizedBox(
                // height : 40,
                child: TextField(
                  controller : oldEmailController,
                  readOnly : true,
                  decoration : InputDecoration(
                    enabledBorder : OutlineInputBorder(
                      borderSide : BorderSide(color : AppColors.mainColor, width : 1)
                    ),
                    focusedBorder : OutlineInputBorder(
                        borderSide : BorderSide(color : AppColors.mainColor, width : 1)
                    ),
                    prefixIcon : Icon(Icons.email, color : AppColors.mainColor),
                  ),
                ),
              ),
              SizedBox(height : 16),
              Text("변경할 이메일", style : TextStyle(fontSize : 20)),
              SizedBox(height : 16),
              // 변경할 이메일
              SizedBox(
                // height : 40,
                child: TextField(
                  controller : newEmailController,
                  decoration : InputDecoration(
                    hintText : "이메일 형식으로",
                    enabledBorder : OutlineInputBorder(
                        borderSide : BorderSide(color : AppColors.mainColor, width : 1)
                    ),
                    focusedBorder : OutlineInputBorder(
                        borderSide : BorderSide(color : AppColors.mainColor, width : 2)
                    ),
                    prefixIcon : Icon(Icons.email, color : AppColors.mainColor),
                  ),
                ),
              ),
              SizedBox(height : 16),
              Text("비밀번호", style : TextStyle(fontSize : 20)),
              SizedBox(height : 16),
              // 비밀번호
              SizedBox(
                // height : 40,
                child: TextField(
                  controller : passwordController,
                  obscureText : _visibility,
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
                          _visibility = !_visibility;
                        });
                      },
                      icon : Icon(_visibility ? Icons.visibility : Icons.visibility_off, color : AppColors.mainColor),
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
                  onPressed: changeEmail,
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
