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

  /// 당화혈색소 데이터
  Map<String, dynamic> hba1cData = {};
  /// 혈당 데이터
  Map<String, dynamic> sugarData = {};
  /// 혈압 데이터
  Map<String, dynamic> pressureData = {};
  /// 혈당 측정 상황 리스트
  List<DropdownMenuEntry<String>> sugarContextList = [];
  /// 혈압 측정 상황 리스트
  List<DropdownMenuEntry<String>> pressureContextList = [];
  /// 선택한 혈당 측정 상황 값
  String? selectSugarContext;
  /// 선택한 혈압 측정 상황 값
  String? selectPressureContext;

  TextEditingController pressureController = TextEditingController();
  TextEditingController sugarController = TextEditingController();

  /// 측정 상황 불러오기
  Future<void> readContext() async {
    try {
      final response = await dio.get("$domain/blood/measurement");
      if(response.statusCode == 200) {
        List<dynamic> result = response.data;
        print(result);
        setState(() {
          for(int index = 0; index < result.length; index++) {
            dynamic temp = result[index];
            sugarContextList.add(
                DropdownMenuEntry(
                  value : temp["mcId"].toString(),
                  label : temp["mcCode"],
                  style : ButtonStyle(
                      textStyle : WidgetStatePropertyAll(TextStyle(fontSize : 16, fontWeight : FontWeight.bold))
                  ),
                )
            );
            pressureContextList.add(
                DropdownMenuEntry(
                  value : temp["mcId"].toString(),
                  label : temp["mcCode"],
                  style : ButtonStyle(
                      textStyle : WidgetStatePropertyAll(TextStyle(fontSize : 16, fontWeight : FontWeight.bold))
                  ),
                )
            );
          }
          sugarController.text = "아침 식전";
          pressureController.text = "아침 식전";
        });
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 400) {
        print("에러");
      }
    }
  }

  /// 로그인 여부
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

  /// 당화혈색소 최근 1개 정보 불러오기
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

  /// 혈당 최소, 최대, 평균 불러오기
  Future<void> findSugarAverage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await dio.get(
        "$domain/blood/sugar/average",
        queryParameters : {"measurementContextLabel" : sugarController.text},
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

  /// 혈압 최소, 최대, 평균 불러오기
  Future<void> findPressureAverage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await dio.get(
        "$domain/blood/pressure/average",
        queryParameters : {"measurementContextLabel" : pressureController.text},
        options : Options(headers : {"Authorization" : token}),
      );
      if(response.statusCode == 200) {
        setState(() { pressureData = response.data; });
        print(response.data);
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 400) {
      }
    }
  }

  /// 최초 1회 실행 함수
  Future<void> initMethod() async {
    await checkLogin();
    if(_isLogin == true) {
      await readContext();
      await findHba1cLatest();
      await findSugarAverage();
      await findPressureAverage();
    } else {
      print("로그인 해주세요");
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initMethod();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child : _isLogin ? SingleChildScrollView(
        child : Container(
          padding : const EdgeInsets.symmetric(horizontal : 16, vertical : 8),
          width : double.infinity,
          child : Column(
            children : [
              // 인사말
              Card(
                color : Colors.white,
                shape : RoundedRectangleBorder(
                  borderRadius : BorderRadius.all(Radius.circular(8.0)),
                  side : BorderSide(color : AppColors.mainColor),
                ),
                child : Container(
                  padding : const EdgeInsets.all(16),
                  width : double.infinity,
                  child : Column(
                    crossAxisAlignment : CrossAxisAlignment.start,
                    children : [
                      Text("안녕하세요!", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                      Text("오늘도 건강한 하루 보내세요.", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                      Text("블러드 메이트와 함께 건강을 기록해 볼까요?", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              SizedBox(height : 8),

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
                      Divider(height : 16, color : AppColors.mainColor),
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
              SizedBox(height : 8),

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
                      SizedBox(height : 8),
                      Row(
                        children: [
                          Expanded(
                            child : LayoutBuilder(
                                builder : (context, size) {
                                  final width = size.maxWidth;
                                  return DropdownMenu<String>(
                                    hintText : "(필수) 선택해주세요",
                                    width : width,
                                    menuHeight : 250,
                                    controller : sugarController,
                                    onSelected : (value) { setState(() { print(value); selectSugarContext = value; }); },
                                    inputDecorationTheme : InputDecorationTheme(
                                      enabledBorder : OutlineInputBorder(
                                        borderRadius : BorderRadius.circular(8.0),
                                        borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                                      ),
                                      focusedBorder : OutlineInputBorder(
                                        borderRadius : BorderRadius.circular(8.0),
                                        borderSide : BorderSide(color : AppColors.mainColor, width : 2),
                                      ),
                                    ),
                                    menuStyle : MenuStyle(
                                      backgroundColor : WidgetStatePropertyAll(Colors.white),
                                      alignment : AlignmentDirectional.bottomStart,
                                      shape : WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius : BorderRadius.circular(8.0),
                                          side : BorderSide(color : AppColors.mainColor),
                                        ),
                                      ),
                                    ),
                                    dropdownMenuEntries : sugarContextList.isEmpty ? [] : sugarContextList,
                                  );
                                }
                            ),
                          ),
                          SizedBox(width : 8),
                          SizedBox(
                            height : 56,
                            child : ElevatedButton(
                              onPressed : findSugarAverage,
                              child : Text("찾기"),
                            ),
                          ),
                        ],
                      ),
                      Divider(height : 16, color : AppColors.mainColor),
                      Text("최소 : ${sugarData["min"]} mg/dL"),
                      SizedBox(height : 8),
                      Text("평균 : ${sugarData["avg"]} mg/dL"),
                      SizedBox(height : 8),
                      Text("최대 : ${sugarData["max"]} mg/dL"),
                    ],
                  ) : null,
                ),
              ),
              SizedBox(height : 8),

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
                      SizedBox(height : 8),
                      Row(
                        children: [
                          Expanded(
                            child : LayoutBuilder(
                                builder : (context, size) {
                                  final width = size.maxWidth;
                                  return DropdownMenu<String>(
                                    hintText : "(필수) 선택해주세요",
                                    width : width,
                                    menuHeight : 250,
                                    controller : pressureController,
                                    onSelected : (value) { setState(() { print(value); selectPressureContext = value; }); },
                                    inputDecorationTheme : InputDecorationTheme(
                                      enabledBorder : OutlineInputBorder(
                                        borderRadius : BorderRadius.circular(8.0),
                                        borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                                      ),
                                      focusedBorder : OutlineInputBorder(
                                        borderRadius : BorderRadius.circular(8.0),
                                        borderSide : BorderSide(color : AppColors.mainColor, width : 2),
                                      ),
                                    ),
                                    menuStyle : MenuStyle(
                                      backgroundColor : WidgetStatePropertyAll(Colors.white),
                                      alignment : AlignmentDirectional.bottomStart,
                                      shape : WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius : BorderRadius.circular(8.0),
                                          side : BorderSide(color : AppColors.mainColor),
                                        ),
                                      ),
                                    ),
                                    dropdownMenuEntries : pressureContextList.isEmpty ? [] : pressureContextList,
                                  );
                                }
                            ),
                          ),
                          SizedBox(width : 8),
                          SizedBox(
                            height : 56,
                            child : ElevatedButton(
                              onPressed : findPressureAverage,
                              child : Text("찾기"),
                            ),
                          ),
                        ],
                      ),
                      Divider(height : 16, color : AppColors.mainColor),
                      Table(
                        border : TableBorder.all(borderRadius : BorderRadius.circular(8.0)),
                        children : [
                          TableRow(
                            children : [
                              Align(alignment : Alignment.center, child : Text("mmHg / 회")),
                              Align(alignment : Alignment.center, child : Text("최소")),
                              Align(alignment : Alignment.center, child : Text("평균")),
                              Align(alignment : Alignment.center, child : Text("최대")),
                            ],
                          ),
                          TableRow(
                            children : [
                              Align(alignment : Alignment.center, child : Text("수축")),
                              Align(alignment : Alignment.center, child : Text("${pressureData["sysMin"]}")),
                              Align(alignment : Alignment.center, child : Text("${pressureData["sysAvg"]}")),
                              Align(alignment : Alignment.center, child : Text("${pressureData["sysMax"]}")),
                            ],
                          ),
                          TableRow(
                            children : [
                              Align(alignment : Alignment.center, child : Text("이완")),
                              Align(alignment : Alignment.center, child : Text("${pressureData["diaMin"]}")),
                              Align(alignment : Alignment.center, child : Text("${pressureData["diaAvg"]}")),
                              Align(alignment : Alignment.center, child : Text("${pressureData["diaMax"]}")),
                            ],
                          ),
                          TableRow(
                            children : [
                              Align(alignment : Alignment.center, child : Text("심박수")),
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
