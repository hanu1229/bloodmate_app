import 'package:bloodmate_app/modals/CustomAlertDialog.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:bloodmate_app/user/user_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteUserPage extends StatefulWidget {

  const DeleteUserPage({super.key});

  @override
  State<DeleteUserPage> createState() => _DeleteUserPageState();
}

class _DeleteUserPageState extends State<DeleteUserPage> {

  Dio dio = Dio();
  final String domain = ServerDomain.domain;
  bool _visibility = true;

  TextEditingController textController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // 회원 탈퇴
  Future<void> deleteUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final data = {"key" : textController.text, "password" : passwordController.text};
      final response = await dio.post("$domain/user/information/delete", data : data, options : Options(headers : {"Authorization" : token}));
      if(response.statusCode == 200) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(
            context : context,
            title : "탈퇴 성공",
            content : "회원탈퇴가 완료되었습니다.",
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
              title : "탈퇴 실패",
              content : "회원 탈퇴에 실패했습니다.",
              isChange : false,
            )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor : Colors.white,
      appBar : AppBar(
        title : Text("회원 탈퇴"),
        backgroundColor : Colors.white,
      ),
      body : Container(
        padding : const EdgeInsets.symmetric(vertical : 16.0, horizontal : 16.0),
        width : double.infinity,
        child : Column(
          crossAxisAlignment : CrossAxisAlignment.start,
          children : [
            Text("※ 계정과 건강 데이터가 영구 삭제됩니다.", style : TextStyle(color : Colors.red, fontSize : 20, fontWeight : FontWeight.bold)),
            Text("※ 복구할 수 없습니다.", style : TextStyle(color : Colors.red, fontSize : 20, fontWeight : FontWeight.bold)),
            SizedBox(height : 16),
            Text("탈퇴를 희망하시면 \"탈퇴\"를 입력해주세요.", style : TextStyle(fontSize : 16)),
            SizedBox(height : 8),
            // 변경할 이메일
            SizedBox(
              child: TextField(
                controller : textController,
                decoration : InputDecoration(
                  hintText : "탈퇴",
                  enabledBorder : OutlineInputBorder(
                      borderSide : BorderSide(color : AppColors.mainColor, width : 1)
                  ),
                  focusedBorder : OutlineInputBorder(
                      borderSide : BorderSide(color : AppColors.mainColor, width : 2)
                  ),
                  prefixIcon : Icon(Icons.check_circle, color : AppColors.mainColor),
                ),
              ),
            ),
            SizedBox(height : 16),
            Text("비밀번호", style : TextStyle(fontSize : 20)),
            SizedBox(height : 8),
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
                  backgroundColor : Colors.red,
                  shape : RoundedRectangleBorder(
                    borderRadius : BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: deleteUser,
                child: Text("회원탈퇴", style : TextStyle(color : Colors.white, fontSize : 16, fontWeight : FontWeight.bold)),
              ),
            ),
            SizedBox(height : 16),
          ],
        ),
      ),
    );
  }
}
