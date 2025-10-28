import 'package:bloodmate_app/board/board_page.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:bloodmate_app/user/login_page.dart';
import 'package:bloodmate_app/user/user_info.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {

  bool _isLogin = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token  = prefs.getString("token");
    if(token != null) {
      _isLogin = true;
    } else {
      _isLogin = false;
    }
    setState(() {});
    print("token : $token");
    print("_isLogin : $_isLogin");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding : const EdgeInsets.symmetric(vertical : 8.0),
      width : double.infinity,
      child : Column(
        children : [
          _isLogin ?
          // 내정보
          Padding(
            padding : const EdgeInsets.symmetric(horizontal : 16.0, vertical : 8.0),
            child : Card(
              color : AppColors.mainColor,
              shape : RoundedRectangleBorder(
                borderRadius : BorderRadius.circular(8.0),
                side : BorderSide(color : AppColors.mainColor),
              ),
              child : InkWell(
                borderRadius : BorderRadius.circular(8.0),
                onTap : () {
                  Navigator.push(context, MaterialPageRoute(builder : (context) => UserInfo()));
                },
                child : Container(
                  padding : const EdgeInsets.symmetric(horizontal : 16.0, vertical : 8.0),
                  width : double.infinity,
                  child: Row(
                    mainAxisAlignment : MainAxisAlignment.spaceBetween,
                    children : [
                      Row(
                        children : [
                          Icon(Icons.person, color : Colors.white),
                          SizedBox(width : 8),
                          Text("내정보", style : TextStyle(color : Colors.white, fontSize : 20, fontWeight : FontWeight.bold)),
                        ],
                      ),
                      Icon(Icons.keyboard_arrow_right, color : Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          )
          :
          Container(
            child : Column(
              children : [
                Text("블러드메이트에", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                Text("오신 것을 환영합니다.", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                SizedBox(height : 8),
                Text("로그인하고 혈당·혈압을 편하게 기록하세요."),
                SizedBox(height : 8),
                SizedBox(
                  child : ElevatedButton(
                    onPressed : () {
                      Navigator.push(context, MaterialPageRoute(builder : (context) => LoginPage()));
                    },
                    child : Text("로그인 / 회원가입"),
                  ),
                ),
              ],
            ),
          ),
          Divider(height : 16, color : AppColors.mainColor),

          // 게시판
          Padding(
            padding : const EdgeInsets.symmetric(horizontal : 16.0, vertical : 8.0),
            child : Card(
              color : Colors.white,
              shape : RoundedRectangleBorder(
                borderRadius : BorderRadius.circular(8.0),
                side : BorderSide(color : AppColors.mainColor),
              ),
              child : InkWell(
                borderRadius : BorderRadius.circular(8.0),
                onTap : () {
                  Navigator.push(context, MaterialPageRoute(builder : (context) => BoardPage()));
                },
                child : Container(
                  padding : const EdgeInsets.symmetric(horizontal : 16.0, vertical : 8.0),
                  width : double.infinity,
                  child: Row(
                    mainAxisAlignment : MainAxisAlignment.spaceBetween,
                    children : [
                      Row(
                        children : [
                          Icon(Icons.article),
                          SizedBox(width : 8),
                          Text("게시판", style : TextStyle(fontSize : 20)),
                        ],
                      ),
                      Icon(Icons.keyboard_arrow_right),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 설정
          Padding(
            padding : const EdgeInsets.symmetric(horizontal : 16.0, vertical : 8.0),
            child : Card(
              color : Colors.white,
              shape : RoundedRectangleBorder(
                borderRadius : BorderRadius.circular(8.0),
                side : BorderSide(color : AppColors.mainColor),
              ),
              child : InkWell(
                borderRadius : BorderRadius.circular(8.0),
                onTap : () {},
                child : Container(
                  padding : const EdgeInsets.symmetric(horizontal : 16.0, vertical : 8.0),
                  width : double.infinity,
                  child: Row(
                    mainAxisAlignment : MainAxisAlignment.spaceBetween,
                    children : [
                      Row(
                        children : [
                          Icon(Icons.settings),
                          SizedBox(width : 8),
                          Text("설정", style : TextStyle(fontSize : 20)),
                        ],
                      ),
                      Icon(Icons.keyboard_arrow_right),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
