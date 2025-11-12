import 'package:bloodmate_app/blood/hba1c/hba1c_page.dart';
import 'package:bloodmate_app/blood/pressure/pressure_page.dart';
import 'package:bloodmate_app/blood/sugar/sugar_page.dart';
import 'package:bloodmate_app/board/board_page.dart';
import 'package:bloodmate_app/dashboard_page.dart';
import 'package:bloodmate_app/more_page.dart';
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
    // 대시보드(홈) 페이지 --> 0
    DashboardPage(),
    // 당화혈색소 페이지 --> 1
    Hba1cPage(),
    // 혈당 페이지 --> 2
    SugarPage(),
    // 혈압 페이지 --> 3
    PressurePage(),
    // 더보기 페이지 --> 4
    MorePage(),
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
            }),
            items : [
              BottomNavigationBarItem(icon : Icon(Icons.home), label : "대시보드", tooltip : "대시보드"),
              BottomNavigationBarItem(icon : Icon(Icons.percent), label : "당화혈색소", tooltip : "당화혈색소"),
              BottomNavigationBarItem(icon : Icon(Icons.water_drop), label : "혈당", tooltip : "혈당"),
              BottomNavigationBarItem(icon : Icon(Icons.monitor_heart), label : "혈압", tooltip : "혈압"),
              BottomNavigationBarItem(icon : Icon(Icons.list), label : "더보기", tooltip : "더보기"),
            ],
            type : BottomNavigationBarType.fixed,
            selectedItemColor : AppColors.mainColor,
            unselectedItemColor : Colors.black,
            backgroundColor : Colors.white,
          ),
        ),
      ),
    );
  }

}