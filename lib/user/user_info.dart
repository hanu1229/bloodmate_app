import 'package:bloodmate_app/main_layout.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
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
  // String title, String infoText
  Widget customCard({required String title, required String infoText}) {
    return Card(
      color : Colors.white,
      shape : RoundedRectangleBorder(
        borderRadius : BorderRadius.all(Radius.circular(8.0)),
        side : BorderSide(color : AppColors.mainColor),
      ),
      child : Container(
        padding : const EdgeInsets.all(16.0),
        width : double.infinity,
        child: Column(
          mainAxisAlignment : MainAxisAlignment.center,
          crossAxisAlignment : CrossAxisAlignment.start,
          children : [
            Text(title, style : TextStyle(fontSize : 16)),
            Text(infoText, style : TextStyle(fontSize : 20,fontWeight : FontWeight.bold)),
          ],
        ),
      ),
    );
  }

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding : const EdgeInsets.symmetric(horizontal : 32.0),
        width : double.infinity,
        child: Column(
          mainAxisAlignment : MainAxisAlignment.center,
          crossAxisAlignment : CrossAxisAlignment.center,
          children : [
            SizedBox(height : 16),
            // 변경 중
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
                  children: [
                    // 이름
                    SizedBox(
                      height : 48,
                      child: Row(
                        children : [
                          SizedBox(
                            width : 60,
                            child: Text("이름", style : TextStyle(fontSize : 20, fontWeight : FontWeight.bold)),
                          ),
                          SizedBox(width : 16),
                          Text(info["userName"] as String? ?? '', style : TextStyle(fontSize : 20,fontWeight : FontWeight.bold)),
                        ],
                      ),
                    ),
                    SizedBox(height : 16),
                    // 생년월일
                    SizedBox(
                      height : 48,
                      child: Row(
                        children : [
                          SizedBox(
                            width : 60,
                            child: Text("생년월일", style : TextStyle(fontSize : 16)),
                          ),
                          SizedBox(width : 16),
                          Text(info["userBirthDate"] as String? ?? '', style : TextStyle(fontSize : 16)),
                        ],
                      ),
                    ),
                    SizedBox(height : 16),
                    // 닉네임
                    SizedBox(
                      height : 48,
                      child: Row(
                        children : [
                          SizedBox(
                            width : 60,
                            child: Text("닉네임", style : TextStyle(fontSize : 16)),
                          ),
                          SizedBox(width : 16),
                          Text(info["userNickname"], style : TextStyle(fontSize : 16)),
                        ],
                      ),
                    ),
                    SizedBox(height : 16),
                    // 이메일
                    SizedBox(
                      height : 48,
                      child: Row(
                        mainAxisAlignment : MainAxisAlignment.spaceBetween,
                        children : [
                          Row(
                            children : [
                              SizedBox(
                                width : 60,
                                child: Text("이메일", style : TextStyle(fontSize : 16), overflow : TextOverflow.ellipsis),
                              ),
                              SizedBox(width : 16),
                              Text(info["userEmail"] as String? ?? '', style : TextStyle(fontSize : 16)),
                            ],
                          ),
                          ElevatedButton(
                            style : ElevatedButton.styleFrom(
                              backgroundColor : AppColors.mainColor,
                              shape : RoundedRectangleBorder(
                                borderRadius : BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: () {},
                            child: Text("수정", style : TextStyle(color : Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height : 16),
                    // 전화번호
                    SizedBox(
                      height : 48,
                      child: Row(
                        mainAxisAlignment : MainAxisAlignment.spaceBetween,
                        children : [
                          Row(
                            children : [
                              SizedBox(
                                width : 60,
                                child: Text("전화번호", style : TextStyle(fontSize : 16), overflow : TextOverflow.ellipsis),
                              ),
                              SizedBox(width : 16),
                              Text(info["userPhone"] as String? ?? '', style : TextStyle(fontSize : 16)),
                            ],
                          ),
                          ElevatedButton(
                            style : ElevatedButton.styleFrom(
                              backgroundColor : AppColors.mainColor,
                              shape : RoundedRectangleBorder(
                                borderRadius : BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: () {},
                            child: Text("수정", style : TextStyle(color : Colors.white)),
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
                      onPressed: () {},
                      child: Text("수정", style : TextStyle(color : Colors.white)),
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
                },
                child : Text("로그아웃", style : TextStyle(color : Colors.white)),
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
                        onPressed: () {},
                        child: Text("탈퇴하기", style : TextStyle(color : Colors.white)),
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
