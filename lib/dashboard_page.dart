import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  Dio dio = Dio();
  String domain = ServerDomain.domain;
  bool _isLogin = false;

  // 당화혈색소 데이터
  Map<String, dynamic> hba1cData = {};
  // 혈당 데이터
  Map<String, dynamic> sugarData = {};
  // 혈압 데이터
  Map<String, dynamic> pressureData = {};

  TextEditingController contextController = TextEditingController();

  // 로그인 여부
  Future<void> checkLogin() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if(token == null) {
        setState(() { _isLogin = false; });
      } else {
        setState(() { _isLogin = true; });
      }
    } catch(e) {

    }
  }

  // 당화혈색소 최근 1개 정보 불러오기
  Future<void> findHba1cLatest() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await dio.get("$domain/blood/hba1c/latest", options : Options(headers : {"Authorization" : token}));
      if(response.statusCode == 200) {
        setState(() { hba1cData = response.data; });
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 400) {

      }
    }
  }

  // 혈당 최소, 최대, 평균 불러오기
  Future<void> findSugarAverage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await dio.get(
        "$domain/blood/sugar/average",
        queryParameters : {"measurementContextLabel" : "아침 식전"},
        options : Options(headers : {"Authorization" : token}),
      );
      if(response.statusCode == 200) {
        setState(() { sugarData = response.data; });
        print(response.data);
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 400) {

      }
    }
  }

  // 혈압 최소, 최대, 평균 불러오기
  Future<void> findPressureAverage() async {
    try {
      print("여기 들어옴1");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await dio.get(
        "$domain/blood/pressure/average",
        queryParameters : {"measurementContextLabel" : "기상"},
        options : Options(headers : {"Authorization" : token}),
      );
      if(response.statusCode == 200) {
        print("여기 들어옴2");
        setState(() { pressureData = response.data; });
        print(response.data);
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 400) {
        print("오류 뜸?");
      }
    }
  }

  // 최초 1회 실행 함수
  Future<void> initMethod() async {
    await findHba1cLatest();
    await findSugarAverage();
    await findPressureAverage();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
    initMethod();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child : _isLogin ? SingleChildScrollView(
        child : Container(
          padding : const EdgeInsets.symmetric(horizontal : 32, vertical : 8),
          width : double.infinity,
          child : Column(
            children : [
              // 최근 당화혈색소 정보
              Card(
                color : Colors.white,
                shape : RoundedRectangleBorder(
                  borderRadius : BorderRadius.all(Radius.circular(8.0)),
                  side : BorderSide(color : AppColors.mainColor),
                ),
                child : Container(
                  padding : const EdgeInsets.all(16),
                  width : double.infinity,
                  child : hba1cData.isNotEmpty ? Column(
                    crossAxisAlignment : CrossAxisAlignment.start,
                    children : [
                      Text("최근 당화혈색소 정보", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                      Divider(height : 16),
                      Text("수치 : ${hba1cData["hba1cValue"]} %"),
                      SizedBox(height : 8),
                      Text(
                        "최근 검사일 : ${hba1cData["measuredAt"].split("T")[0]} ${hba1cData["measuredAt"].split("T")[1].split(":")[0]}:${hba1cData["measuredAt"].split("T")[1].split(":")[1]}",
                      ),
                      SizedBox(height : 8),
                      Text(
                        "다음 검사일 : ${hba1cData["nextTestAt"].split("T")[0]} ${hba1cData["nextTestAt"].split("T")[1].split(":")[0]}:${hba1cData["nextTestAt"].split("T")[1].split(":")[1]}",
                      ),
                    ],
                  ) : null,
                ),
              ),

              // 혈당
              Card(
                color : Colors.white,
                shape : RoundedRectangleBorder(
                  borderRadius : BorderRadius.all(Radius.circular(8.0)),
                  side : BorderSide(color : AppColors.mainColor),
                ),
                child : Container(
                  padding : const EdgeInsets.all(16),
                  width : double.infinity,
                  child : sugarData.isNotEmpty ? Column(
                    crossAxisAlignment : CrossAxisAlignment.start,
                    children : [
                      Text("혈당 최근 수치", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                      Divider(height : 16),
                      Text("최소 : ${sugarData["min"]} mg/dL"),
                      SizedBox(height : 8),
                      Text("평균 : ${sugarData["avg"]} mg/dL"),
                      SizedBox(height : 8),
                      Text("최대 : ${sugarData["max"]} mg/dL"),
                    ],
                  ) : null,
                ),
              ),

              // 혈압
              Card(
                color : Colors.white,
                shape : RoundedRectangleBorder(
                  borderRadius : BorderRadius.all(Radius.circular(8.0)),
                  side : BorderSide(color : AppColors.mainColor),
                ),
                child : Container(
                  padding : const EdgeInsets.all(16),
                  width : double.infinity,
                  child : pressureData.isNotEmpty ? Column(
                    crossAxisAlignment : CrossAxisAlignment.start,
                    children : [
                      Text("혈압 최근 수치", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                      Divider(height : 16),
                      Table(
                        border : TableBorder.all(),
                        children : [
                          TableRow(
                            children : [
                              Align(alignment : Alignment.center, child : Text("수치")),
                              Align(alignment : Alignment.center, child : Text("최소")),
                              Align(alignment : Alignment.center, child : Text("평균")),
                              Align(alignment : Alignment.center, child : Text("최대")),
                            ],
                          ),
                          TableRow(
                            children : [
                              Align(alignment : Alignment.center, child : Text("수축(mmHg)")),
                              Align(alignment : Alignment.center, child : Text("${pressureData["sysMin"]}")),
                              Align(alignment : Alignment.center, child : Text("${pressureData["sysAvg"]}")),
                              Align(alignment : Alignment.center, child : Text("${pressureData["sysMax"]}")),
                            ],
                          ),
                          TableRow(
                            children : [
                              Align(alignment : Alignment.center, child : Text("이완(mmHg)")),
                              Align(alignment : Alignment.center, child : Text("${pressureData["diaMin"]}")),
                              Align(alignment : Alignment.center, child : Text("${pressureData["diaAvg"]}")),
                              Align(alignment : Alignment.center, child : Text("${pressureData["diaMax"]}")),
                            ],
                          ),
                          TableRow(
                            children : [
                              Align(alignment : Alignment.center, child : Text("심박수(회)")),
                              Align(alignment : Alignment.center, child : Text("${pressureData["pulseMin"]}")),
                              Align(alignment : Alignment.center, child : Text("${pressureData["pulseAvg"]}")),
                              Align(alignment : Alignment.center, child : Text("${pressureData["pulseMax"]}")),
                            ],
                          ),
                          // TableRow(),
                          // TableRow(),
                        ],
                      ),
                    ],
                  ) : null,
                ),
              ),

            ],
          ),
        ),
      ) : Center(
        child : Text("로그인해주세요!"),
      ),
    );
  }
}
