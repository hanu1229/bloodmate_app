import 'package:bloodmate_app/blood/hba1c/create_hba1c_page.dart';
import 'package:bloodmate_app/blood/hba1c/delete_hba1c_page.dart';
import 'package:bloodmate_app/blood/hba1c/update_hba1c_page.dart';
import 'package:bloodmate_app/modals/CustomAlertDialog.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:bloodmate_app/user/login_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Hba1cPage extends StatefulWidget {
  /// <b>당화혈색소 페이지</b>
  const Hba1cPage({super.key});

  @override
  State<Hba1cPage> createState() => _Hba1cPageState();

}

class _Hba1cPageState extends State<Hba1cPage> {

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

  // 당화혈색소 데이터 불러오기
  Future<void> readData() async {
    setState(() { _isLoading = true; });
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      final response = await dio.get(
        "$domain/blood/hba1c",
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

  Future<void> update() async {

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
                        final result = await Navigator.push(context, MaterialPageRoute(builder : (context) => CreateHba1cPage()));
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
                          child : Card(
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
                                  Row(
                                    children : [
                                      Icon(Icons.water_drop, color : AppColors.mainColor, size : 32),
                                      SizedBox(width : 16),
                                      Column(
                                        crossAxisAlignment : CrossAxisAlignment.start,
                                        children: [
                                          Text("$date\n$time", style : TextStyle(fontSize : 16)),
                                          SizedBox(height : 8),
                                          Text("수치 : ${info['hba1cValue']}%", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                                        ],
                                      ),
                                    ],
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
                                                            builder : (context) => UpdateHba1cPage(
                                                              hba1cId : info["hba1cId"],
                                                              date : date,
                                                              time : time,
                                                              value : info["hba1cValue"],
                                                              next : info["nextTestAt"],
                                                            ),
                                                          ),
                                                        );
                                                        if(result != null) {
                                                          if(info["hba1cId"] == result["hba1cId"]) {
                                                            setState(() {
                                                              info["measuredAt"] = "${result["date"]}T${result["time"]}";
                                                              info["hba1cValue"] = result["value"];
                                                              info["nextTestAt"] = result["next"];
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
                                                          builder : (context) => DeleteHba1cPage(hba1cId : info["hba1cId"])
                                                        );
                                                        if(result != null && result == info["hba1cId"]) {
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