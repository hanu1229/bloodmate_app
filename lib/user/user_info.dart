import 'package:bloodmate_app/main_layout.dart';
import 'package:bloodmate_app/modals/CustomAlertDialog.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:bloodmate_app/user/delete_user_page.dart';
import 'package:bloodmate_app/user/email_change_page.dart';
import 'package:bloodmate_app/user/password_change_page.dart';
import 'package:bloodmate_app/user/phone_change_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {

  Dio dio = Dio();
  String domain = ServerDomain.domain;
  Map<String, dynamic> info = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadInfo();
  }

  // 이메일 수정 페이지
  void openEmailPage() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder : (context) => EmailChangePage(email : info["userEmail"] as String? ?? ""))
    );
    if(result) {
      loadInfo();
    }
  }

  // 전화번호 수정 페이지
  void openPhonePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PhoneChangePage(phone : info["userPhone"] as String? ?? ""))
    );
    if(result) {
      loadInfo();
    }
  }

  // 비밀번호 수정 페이지
  void openPasswordPage() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PasswordChangePage())
    );
    if(result) {
      logout();
    }
  }

  // 회원 탈퇴 페이지
  void openDeletePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder : (context) => DeleteUserPage())
    );
    if(result) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("token");
      Navigator.pushReplacement(context, MaterialPageRoute( builder: (context) => MainLayout() ));
    }
  }

  // 로그아웃
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final token = prefs.getString("token");
      final response = await dio.post("${ServerDomain.domain}/user/logout", options : Options(headers : {"Authorization" : token}));
      if(response.data) {
        prefs.remove("token");
      }
    } catch(e) {
      print("로그아웃 실패");
    }
    // 홈으로 화면을 옮김
    Navigator.pushReplacement(context, MaterialPageRoute( builder: (context) => MainLayout() ));
  }

  // 내정보 로드
  Future<void> loadInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    try {
      final response = await dio.get("${domain}/user/information", options : Options(headers : {"Authorization" : token}));
      if(response.statusCode == 200) {
        setState(() {
          info = response.data;
          print("info : $info");
        });
      }
    } catch(e) {
      print("에러!!!");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("token");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding : const EdgeInsets.symmetric(horizontal : 32.0, vertical : 16.0),
        width : double.infinity,
        child: Column(
          mainAxisAlignment : MainAxisAlignment.center,
          crossAxisAlignment : CrossAxisAlignment.center,
          children : [
            Card(
              color : Colors.white,
              shape : RoundedRectangleBorder(
                borderRadius : BorderRadius.all(Radius.circular(8.0)),
                side : BorderSide(color : AppColors.mainColor),
              ),
              child : Container(
                padding : const EdgeInsets.all(16.0),
                width : double.infinity,
                child: Column(
                  mainAxisAlignment : MainAxisAlignment.spaceBetween,
                  crossAxisAlignment : CrossAxisAlignment.start,
                  children: [
                    // 이름
                    SizedBox(
                      width : double.infinity,
                      height : 48,
                      child: Column(
                        mainAxisAlignment : MainAxisAlignment.spaceBetween,
                        crossAxisAlignment : CrossAxisAlignment.start,
                        children : [
                          Text("이름", style : TextStyle(fontSize : 16)),
                          Text(info["userName"] as String? ?? "", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold, overflow : TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                    Divider(),
                    // 생년월일
                    SizedBox(
                      height : 48,
                      child: Column(
                        mainAxisAlignment : MainAxisAlignment.spaceBetween,
                        crossAxisAlignment : CrossAxisAlignment.start,
                        children : [
                          Text("생년월일", style : TextStyle(fontSize : 16)),
                          Text(info["userBirthDate"] as String? ?? "", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold, overflow : TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                    Divider(),
                    // 닉네임
                    SizedBox(
                      height : 48,
                      child: Column(
                        mainAxisAlignment : MainAxisAlignment.spaceBetween,
                        crossAxisAlignment : CrossAxisAlignment.start,
                        children : [
                          Text("닉네임", style : TextStyle(fontSize : 16)),
                          Text(info["userNickname"] as String? ?? "", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold, overflow : TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                    Divider(),
                    // 이메일
                    SizedBox(
                      width : double.infinity,
                      height : 48,
                      child : Row(
                        mainAxisAlignment : MainAxisAlignment.spaceBetween,
                        children : [
                          Expanded(
                            child: Column(
                              mainAxisAlignment : MainAxisAlignment.spaceBetween,
                              crossAxisAlignment : CrossAxisAlignment.start,
                              children : [
                                Text("이메일", style : TextStyle(fontSize : 16), overflow : TextOverflow.ellipsis),
                                Tooltip(
                                  triggerMode : TooltipTriggerMode.longPress,
                                  showDuration : Duration(seconds : 3),
                                  decoration : BoxDecoration(color : AppColors.mainColor, borderRadius : BorderRadius.circular(8.0)),
                                  textStyle : TextStyle(color : Colors.white, fontSize : 16, fontWeight : FontWeight.bold),
                                  message : info["userEmail"] as String? ?? "",
                                  child : Text(
                                    info["userEmail"] as String? ?? "",
                                    style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold), overflow : TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style : ElevatedButton.styleFrom(
                              backgroundColor : AppColors.mainColor,
                              shape : RoundedRectangleBorder(
                                borderRadius : BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed : openEmailPage,
                            child : Text("수정", style : TextStyle(color : Colors.white, fontSize : 16, fontWeight : FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    // 전화번호
                    SizedBox(
                      height : 48,
                      child: Row(
                        mainAxisAlignment : MainAxisAlignment.spaceBetween,
                        children : [
                          Expanded(
                            child: Column(
                              mainAxisAlignment : MainAxisAlignment.spaceBetween,
                              crossAxisAlignment : CrossAxisAlignment.start,
                              children : [
                                Text("전화번호", style : TextStyle(fontSize : 16)),
                                Text(info["userPhone"] as String? ?? "", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold, overflow : TextOverflow.ellipsis)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style : ElevatedButton.styleFrom(
                              backgroundColor : AppColors.mainColor,
                              shape : RoundedRectangleBorder(
                                borderRadius : BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: openPhonePage,
                            child : Text("수정", style : TextStyle(color : Colors.white, fontSize : 16, fontWeight : FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 비밀번호 변경 카드
            Card(
              color : Colors.white,
              shape : RoundedRectangleBorder(
                borderRadius : BorderRadius.all(Radius.circular(8.0)),
                side : BorderSide(color : AppColors.mainColor),
              ),
              child : Container(
                padding : const EdgeInsets.all(16.0),
                width : double.infinity,
                child: Row(
                  mainAxisAlignment : MainAxisAlignment.spaceBetween,
                  children : [
                    Text("비밀번호", style : TextStyle(fontSize : 16)),
                    ElevatedButton(
                      style : ElevatedButton.styleFrom(
                        backgroundColor : AppColors.mainColor,
                        shape : RoundedRectangleBorder(
                          borderRadius : BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed : openPasswordPage,
                      child : Text("수정", style : TextStyle(color : Colors.white, fontSize : 16, fontWeight : FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            // 로그아웃 버튼
            Container(
              padding : const EdgeInsets.symmetric(horizontal : 8.0),
              width : double.infinity,
              child: ElevatedButton(
                style : ElevatedButton.styleFrom(
                  backgroundColor : AppColors.mainColor,
                  shape : RoundedRectangleBorder(
                    borderRadius : BorderRadius.circular(8.0),
                  ),
                ),
                onPressed : () async {
                  await showDialog(
                    context : context,
                    builder : (context) => AlertDialog(
                      backgroundColor : Colors.white,
                      title : Text("로그아웃"),
                      content : Text("정말 로그아웃 하시겠습니까?"),
                      actions : [
                        ElevatedButton(
                          style : ElevatedButton.styleFrom(
                            backgroundColor : AppColors.mainColor,
                            shape : RoundedRectangleBorder(
                              borderRadius : BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed : logout,
                          child : Text("확인", style : TextStyle(color : Colors.white, fontSize : 16, fontWeight : FontWeight.bold)),
                        ),
                        ElevatedButton(
                          style : ElevatedButton.styleFrom(
                            backgroundColor : Colors.grey,
                            shape : RoundedRectangleBorder(
                              borderRadius : BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed : () {
                            Navigator.pop(context);
                          },
                          child : Text("취소", style : TextStyle(color : Colors.white, fontSize : 16, fontWeight : FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                child : Text("로그아웃", style : TextStyle(color : Colors.white, fontSize : 16, fontWeight : FontWeight.bold)),
              ),
            ),
            // 회원탈퇴 카드
            Card(
              color : Colors.white,
              shape : RoundedRectangleBorder(
                borderRadius : BorderRadius.all(Radius.circular(8.0)),
                side : BorderSide(color : AppColors.mainColor),
              ),
              child : Container(
                padding : const EdgeInsets.all(16.0),
                width : double.infinity,
                child: Column(
                  crossAxisAlignment : CrossAxisAlignment.start,
                  children : [
                    Row(
                      children: [
                        Icon(Icons.dangerous, color : Colors.red),
                        Text("회원탈퇴", style : TextStyle(color : Colors.red, fontSize : 20, fontWeight : FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height : 16.0),
                    Text("※ 계정과 건강 데이터가 영구 삭제됩니다.", style : TextStyle(fontSize : 16)),
                    Text("※ 복구할 수 없습니다.", style : TextStyle(fontSize : 16)),
                    SizedBox(height : 16.0),
                    SizedBox(
                      width : double.infinity,
                      child: ElevatedButton(
                        style : ElevatedButton.styleFrom(
                          backgroundColor : Colors.red,
                          shape : RoundedRectangleBorder(
                            borderRadius : BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed : openDeletePage,
                        child : Text("탈퇴하기", style : TextStyle(color : Colors.white, fontSize : 16, fontWeight : FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
