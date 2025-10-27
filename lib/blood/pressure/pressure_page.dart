import 'package:bloodmate_app/blood/pressure/create_pressure_page.dart';
import 'package:bloodmate_app/blood/pressure/delete_pressure_page.dart';
import 'package:bloodmate_app/blood/pressure/update_pressure_page.dart';
import 'package:bloodmate_app/blood/sugar/create_sugar_page.dart';
import 'package:bloodmate_app/blood/sugar/delete_sugar_page.dart';
import 'package:bloodmate_app/blood/sugar/update_sugar_page.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:bloodmate_app/user/login_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PressurePage extends StatefulWidget {

  /// <b>혈당 페이지</b>
  const PressurePage({super.key});

  @override
  State<PressurePage> createState() => _PressurePageState();
}

class _PressurePageState extends State<PressurePage> {

  Dio dio = Dio();
  String domain = ServerDomain.domain;

  final ScrollController _scroll = ScrollController();

  // 페이지 인덱스
  int page = 0;
  // 페이지 크기
  int size = 5;
  // 정렬 상태
  String sorting = "DESC";
  // 전송받은 데이터
  List<dynamic> item = [];

  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 첫 페이지 로드
    readData();
    // 무한 스크롤 적용
    // _scroll.addListener(() {
    //   if(_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200 && !_isLoading && _hasMore) {
    //     readData();
    //   }
    // });
  }

  // 혈당 데이터 불러오기
  Future<void> readData() async {
    setState(() { _isLoading = true; });
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      final response = await dio.get(
        "$domain/blood/pressure",
        options : Options(headers : {"Authorization" : token}),
        queryParameters : {"page" : page + 1, "size" : size, "sorting" : sorting},
      );
      print(response.data);
      if(response.statusCode == 200) {
        setState(() {
          item.addAll(response.data["content"]);
          _hasMore = !response.data["last"];
          page++;
        });
      }
    } on DioException catch(e) {
      print(e);
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> refresh() async {
    page = 0; _hasMore = true; item.clear();
    await readData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children : [
        Stack(
          children : [
            Column(
              children : [
                Container(
                  padding : const EdgeInsets.symmetric(horizontal : 32.0, vertical : 8.0),
                  width : double.infinity,
                  child : ElevatedButton(
                    onPressed : () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString("token");
                      if(token != null) {
                        final result = await Navigator.push(context, MaterialPageRoute(builder : (context) => CreatePressurePage()));
                        if(result != null) {
                          // setState(() { refresh(); });
                          setState(() { item.insert(0, result); });
                        }
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder : (context) => LoginPage()));
                      }
                    },
                    child : Text("추가하기"),
                  ),
                ),
                Container(
                  width : double.infinity,
                  height : 1,
                  decoration : BoxDecoration(
                    color : AppColors.mainColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child : Container(
            padding : const EdgeInsets.symmetric(horizontal : 32.0, vertical : 8.0),
            width : double.infinity,
            child: Column(
              crossAxisAlignment : CrossAxisAlignment.start,
              children : [
                item.isEmpty ? SizedBox.shrink() : Expanded(
                  child : RefreshIndicator(
                    onRefresh : refresh,
                    child : ListView.builder(
                        controller : _scroll,
                        physics : AlwaysScrollableScrollPhysics(),
                        itemCount : _hasMore ? item.length + 1 : item.length,
                        itemBuilder : (context, index) {

                          if(index >= item.length) {
                            if(_isLoading) {
                              return Center(
                                child : CircularProgressIndicator(),
                              );
                            }
                            if(_hasMore) {
                              return Container(
                                width : double.infinity,
                                child : ElevatedButton(
                                  onPressed : () { if(_hasMore) { readData(); } },
                                  child : Text("불러오기"),
                                ),
                              );
                            }
                            return Center(child : Text("마지막입니다."));
                          }

                          dynamic info = item[index];
                          List<String> measuredAt = info["measuredAt"].toString().split("T");
                          List<String> timeList = measuredAt[1].split(":");
                          String date = measuredAt[0];
                          String time = "${timeList[0]}:${timeList[1]}";

                          return Padding(
                            padding : const EdgeInsets.only(bottom : 8.0),
                            child: Card(
                              color : Colors.white,
                              shape : RoundedRectangleBorder(
                                borderRadius : BorderRadius.circular(8.0),
                                side : BorderSide(color : AppColors.mainColor),
                              ),
                              child : Container(
                                padding : const EdgeInsets.all(16.0),
                                child : Row(
                                  mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children : [
                                          Icon(Icons.monitor_heart, color : AppColors.mainColor, size : 32),
                                          SizedBox(width : 16),
                                          Expanded(
                                            child : Column(
                                              crossAxisAlignment : CrossAxisAlignment.stretch,
                                              children: [
                                                Text(date, style : TextStyle(fontSize : 16)),
                                                Row(
                                                  mainAxisAlignment : MainAxisAlignment.start,
                                                  children : [
                                                    Text(time, style : TextStyle(fontSize : 16)),
                                                    Text(" | ", style : TextStyle(fontSize : 16)),
                                                    Text(info["measurementContextLabel"], style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                                                  ],
                                                ),
                                                SizedBox(height : 8),
                                                Text("수축기 : ${info['bloodPressureSystolic']} mmHg", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                                                Text("이완기 : ${info['bloodPressureDiastolic']} mmHg", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                                                Text("심박수 : ${info['bloodPressurePulse']} 회", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed : () async {
                                        await showModalBottomSheet(
                                          context : context,
                                          isScrollControlled : true,
                                          useSafeArea : true,
                                          backgroundColor : Colors.transparent,
                                          builder : (context) => Padding(
                                            padding : const EdgeInsets.all(16),
                                            child: SafeArea(
                                              child : Container(
                                                padding : const EdgeInsets.symmetric(horizontal : 32, vertical : 16),
                                                height : 150,
                                                width : double.infinity,
                                                decoration : BoxDecoration(
                                                  color : Colors.white,
                                                  borderRadius : BorderRadius.circular(16.0),
                                                ),
                                                child : Column(
                                                  mainAxisAlignment : MainAxisAlignment.spaceAround,
                                                  children : [
                                                    // 수정 버튼
                                                    SizedBox(
                                                      width : double.infinity,
                                                      child : ElevatedButton(
                                                        onPressed : () async {
                                                          final result = await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder : (context) => UpdatePressurePage(
                                                                  bloodPressureId : info["bloodPressureId"],
                                                                  bloodPressureSystolic : info["bloodPressureSystolic"],
                                                                  bloodPressureDiastolic : info["bloodPressureDiastolic"],
                                                                  bloodPressurePulse : info["bloodPressurePulse"],
                                                                  date : date,
                                                                  time : time,
                                                                  measurementContextId : info["measurementContextId"],
                                                                  measurementContextLabel : info["measurementContextLabel"]
                                                              ),
                                                            ),
                                                          );
                                                          if(result != null) {
                                                            if(info["bloodPressureId"] == result["bloodPressureId"]) {
                                                              print("여기 들어옴?");
                                                              setState(() {
                                                                info["measuredAt"] = "${result["date"]}T${result["time"]}";
                                                                info["bloodPressureSystolic"] = result["bloodPressureSystolic"];
                                                                info["bloodPressureDiastolic"] = result["bloodPressureDiastolic"];
                                                                info["bloodPressurePulse"] = result["bloodPressurePulse"];
                                                                info["measurementContextLabel"] = result["measurementContextLabel"];
                                                              });
                                                            }
                                                          }
                                                          Navigator.pop(context);
                                                        },
                                                        child : Text("수정하기"),
                                                      ),
                                                    ),
                                                    // 삭제 버튼
                                                    SizedBox(
                                                      width : double.infinity,
                                                      child : ElevatedButton(
                                                        style : ElevatedButton.styleFrom(
                                                          backgroundColor : Colors.red,
                                                          shape : RoundedRectangleBorder(borderRadius : BorderRadius.circular(8.0)),
                                                        ),
                                                        onPressed : () async {
                                                          final result = await showDialog(
                                                              context : context,
                                                              barrierDismissible : false,
                                                              builder : (context) => DeletePressurePage(bloodPressureId : info["bloodPressureId"])
                                                          );
                                                          if(result != null && result == info["bloodPressureId"]) {
                                                            setState(() { item.removeAt(index); });
                                                            Navigator.pop(context);
                                                          }
                                                        },
                                                        child : Text("삭제하기"),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      icon : Icon(Icons.more_horiz, color : AppColors.mainColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
