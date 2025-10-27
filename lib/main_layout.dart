import 'package:bloodmate_app/blood/hba1c/create_hba1c_page.dart';
import 'package:bloodmate_app/blood/hba1c/hba1c_page.dart';
import 'package:bloodmate_app/blood/pressure/pressure_page.dart';
import 'package:bloodmate_app/blood/sugar/create_sugar_page.dart';
import 'package:bloodmate_app/blood/sugar/sugar_page.dart';
import 'package:bloodmate_app/board/board_page.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:bloodmate_app/user/login_page.dart';
import 'package:bloodmate_app/user/user_info.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainLayout extends StatefulWidget {

  @override
  State<MainLayout> createState() => _MainLayoutState();

}

class _MainLayoutState extends State<MainLayout> {

  int indexNumber = 0;
  bool _showFAB = true;
  SharedPreferences? ps;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadPrefs();
  }

  Future<void> loadPrefs() async {
    ps = await SharedPreferences.getInstance();
    if(!mounted) { return; }
    setState(() {});
  }

  final List<Widget> pages = [
    // 당화혈색소 페이지 --> 0
    Hba1cPage(),
    // 혈당 페이지 --> 1
    SugarPage(),
    // 혈압 페이지 --> 2
    PressurePage(),
    // 게시판 페이지 --> 3
    BoardPage(),
    // 내정보 페이지 --> 4
    UserInfo(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor : Colors.white,
      appBar : AppBar(
        title : Text("블러드 메이트", style : TextStyle(color : AppColors.mainColor, fontWeight : FontWeight.bold)),
        backgroundColor : Colors.white,
        shape : Border(bottom : BorderSide(color : AppColors.mainColor, width : 1)),
        leading : Padding(
          padding: const EdgeInsets.only(top : 8.0, right : 0.0, bottom : 8.0, left : 8.0),
          child: SizedBox(
              width : 48,
              height : 48,
              child : Image.asset("assets/images/bloodmate_logo-default.png")
          ),
        ),
        // actions : [
        //   IconButton(
        //     onPressed : () async {
        //       final token = ps?.getString("token");
        //       print("token : $token");
        //       if(indexNumber == 0) {
        //         bool? result = await Navigator.push(context, MaterialPageRoute(builder : (context) => CreateHba1cPage()));
        //         if(result != null && result == true) {
        //           // 이곳으로....
        //         }
        //       } else if(indexNumber == 1) {
        //         bool? result = await Navigator.push(context, MaterialPageRoute(builder : (context) => CreateSugarPage()));
        //       }
        //     },
        //     icon : Icon(Icons.add, color : AppColors.mainColor),
        //   ),
        //   SizedBox(width : 12),
        // ],
      ),
      body : pages[indexNumber],
      bottomNavigationBar : Container(
        decoration : BoxDecoration(
          border : Border(top : BorderSide(color : AppColors.mainColor, width : 1))
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex : indexNumber,
            onTap : (index) => setState(() {
              indexNumber = index;
              print("index : $indexNumber");
              if(indexNumber == 4) {
                final token = ps?.getString("token");
                if(token == null || token.isEmpty) {
                  indexNumber = 0;
                  Navigator.push(context, MaterialPageRoute(builder : (context) => LoginPage()));
                }
              }
            }),
            items : [
              BottomNavigationBarItem(icon : Icon(Icons.percent),label : "당화혈색소", tooltip : "당화혈색소"), 
              BottomNavigationBarItem(icon : Icon(Icons.water_drop),label : "혈당", tooltip : "혈당"),
              BottomNavigationBarItem(icon : Icon(Icons.monitor_heart),label : "혈압", tooltip : "혈압"),
              BottomNavigationBarItem(icon : Icon(Icons.article),label : "게시판", tooltip : "게시판"),
              BottomNavigationBarItem(icon : Icon(Icons.person),label : "내정보", tooltip : "내정보"),
            ],
            type : BottomNavigationBarType.fixed,
            selectedItemColor : AppColors.mainColor,
            unselectedItemColor : Colors.black,
            backgroundColor : Colors.white,
          ),
        ),
      ),
      // floatingActionButton : indexNumber == 4 ? null : _showFAB ? FloatingActionButton(
      //   onPressed : () async {
      //     final token = ps?.getString("token");
      //     print("token : $token");
      //     if(indexNumber == 0) {
      //       bool? result = await Navigator.push(context, MaterialPageRoute(builder : (context) => CreateHba1cPage()));
      //     } else if(indexNumber == 1) {
      //       bool? result = await Navigator.push(context, MaterialPageRoute(builder : (context) => CreateSugarPage()));
      //     }
      //   },
      //   backgroundColor : AppColors.mainColor,
      //   child : Icon(Icons.add, color : Colors.white),
      // ) : null,
    );
  }

}