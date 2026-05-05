import 'package:bloodmate_app/blood/sugar/create_sugar_page.dart';
import 'package:bloodmate_app/blood/sugar/delete_sugar_page.dart';
import 'package:bloodmate_app/blood/sugar/update_sugar_page.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:bloodmate_app/user/login_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SugarPage extends StatefulWidget {
  
  /// <b>혈당 페이지</b>
  const SugarPage({super.key});

  @override
  State<SugarPage> createState() => _SugarPageState();
}

class _SugarPageState extends State<SugarPage> {

  Dio dio = Dio();
  String domain = ServerDomain.domain;

  final ScrollController _scroll = ScrollController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController contextController = TextEditingController();
  TextEditingController sortingController = TextEditingController();

  /// 측정 상황 리스트
  List<DropdownMenuEntry<String>> contextList = [
    DropdownMenuEntry(value: "0", label: "전체")
  ];
  /// 선택한 측정 상황 값
  String? selectContext;

  /// 정렬 방식 리스트
  List<DropdownMenuEntry<String>> sortingList = [
    DropdownMenuEntry(value : "DESC", label : "내림차순"),
    DropdownMenuEntry(value : "ASC", label : "오름차순"),
  ];
  /// 선택한 정렬 방식 값
  String? selectSorting = "DESC";

  // 총 데이터 개수
  int? totalElements;
  // 페이지 인덱스
  int page = 0;
  // 페이지 크기
  int size = 10;
  // 정렬 상태
  String sorting = "DESC";
  // 전송받은 데이터
  List<dynamic> item = [];

  bool _isLoading = false;
  bool _hasMore = true;

  // 조건 조회 중인 지 확인 하는 변수
  bool _isFilter = false;

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
            contextList.add(
                DropdownMenuEntry(
                  value : temp["mcId"].toString(),
                  label : temp["mcCode"],
                  style : ButtonStyle(
                      textStyle : WidgetStatePropertyAll(TextStyle(fontSize : 16, fontWeight : FontWeight.bold))
                  ),
                )
            );
          }
        });
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 400) {
        print("에러");
      }
    }
  }

  void printLongText(String text) {
    const int chunkSize = 800;

    for (int i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      print(text.substring(i, end));
    }
  }

  /** 혈당 데이터 불러오기 */
  Future<void> readData() async {
    setState(() { _isLoading = true; });
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      dynamic response;
      if(_isFilter == true) {
        print("startDateController.text : ${startDateController.text}");
        print("endDateController.text : ${endDateController.text}");
        print("selectContext : $selectContext");
        print("page : ${page + 1}");
        print("size : $size");
        print("sortingController.text : ${sortingController.text}");
        response = await dio.get(
          "$domain/blood/sugar/date",
          options : Options(headers : {"Authorization" : token}),
          queryParameters : {
            "startDate" : startDateController.text, "endDate": endDateController.text,
            "context" : int.parse(selectContext!), "page" : page + 1, "size" : size, "sorting" : sortingController.text
          },
        );
      } else {
        response = await dio.get(
          "$domain/blood/sugar",
          options : Options(headers : {"Authorization" : token}),
          queryParameters : {"page" : page + 1, "size" : size, "sorting" : sorting},
        );
      }
      print(response.data);
      // final prettyJson = const JsonEncoder.withIndent('  ').convert(response.data);
      // printLongText(prettyJson);
      if(response.statusCode == 200) {
        setState(() {
          item.addAll(response.data["content"]);
          _hasMore = !response.data["last"];
          totalElements = response.data["totalElements"];
          page++;
          print("asd page : $page");
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
                Row(
                  mainAxisAlignment : MainAxisAlignment.end,
                  children: [
                    totalElements == null ? SizedBox.shrink() : Text("조회된 결과 : $totalElements개"),
                    SizedBox(width : 8),
                    /** 조건조회 버튼 */
                    Container(
                      margin : const EdgeInsets.symmetric(horizontal : 4.0, vertical : 8.0),
                      // width : double.infinity,
                      child : ElevatedButton(
                        onPressed : () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString("token");
                          await readContext();
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
                                  height : 350,
                                  width : double.infinity,
                                  decoration : BoxDecoration(
                                    color : Colors.white,
                                    borderRadius : BorderRadius.circular(16.0),
                                  ),
                                  child : Column(
                                    mainAxisAlignment : MainAxisAlignment.start,
                                    children : [
                                      // 측정일
                                      SizedBox(
                                        width : double.infinity,
                                        child : Text("측정일 (예시 : 2025-01-01)", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                                      ),
                                      SizedBox(height : 8),
                                      Container(
                                        width : double.infinity,
                                        child: Row(
                                          mainAxisAlignment : MainAxisAlignment.start,
                                          children : [
                                            /** startDate */
                                            Expanded(
                                              child: TextField(
                                                controller : startDateController,
                                                readOnly : true,
                                                decoration : InputDecoration(
                                                  hintText : "YYYY-MM-DD",
                                                  contentPadding : EdgeInsets.symmetric(horizontal : 8, vertical : 8),
                                                  enabledBorder : OutlineInputBorder(
                                                    borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                                                  ),
                                                  focusedBorder : OutlineInputBorder(
                                                    borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                                                  ),
                                                ),
                                                onTap : () async {
                                                  final result = await showDatePicker(
                                                    context : context,
                                                    initialDate : DateTime.now(),
                                                    firstDate : DateTime(1900),
                                                    lastDate : DateTime(2100),
                                                    barrierDismissible : false,
                                                  );
                                                  String year, month, day;
                                                  if(result != null) {
                                                    year = result.year > 9 ? result.year.toString() : "0${result.year}";
                                                    month = result.month > 9 ? result.month.toString() : "0${result.month}";
                                                    day = result.day > 9 ? result.day.toString() : "0${result.day}";
                                                    setState(() { startDateController.text = "$year-$month-$day"; });
                                                  }
                                                },
                                              ),
                                            ),
                                            SizedBox(child : Text(" ~ ")),
                                            /** endDate */
                                            Expanded(
                                              child: TextField(
                                                controller : endDateController,
                                                readOnly : true,
                                                decoration : InputDecoration(
                                                  hintText : "YYYY-MM-DD",
                                                  contentPadding : EdgeInsets.symmetric(horizontal : 8, vertical : 8),
                                                  enabledBorder : OutlineInputBorder(
                                                    borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                                                  ),
                                                  focusedBorder : OutlineInputBorder(
                                                    borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                                                  ),
                                                ),
                                                onTap : () async {
                                                  final result = await showDatePicker(
                                                    context : context,
                                                    initialDate : DateTime.now(),
                                                    firstDate : DateTime(1900),
                                                    lastDate : DateTime(2100),
                                                    barrierDismissible : false,
                                                  );
                                                  String year, month, day;
                                                  if(result != null) {
                                                    year = result.year > 9 ? result.year.toString() : "0${result.year}";
                                                    month = result.month > 9 ? result.month.toString() : "0${result.month}";
                                                    day = result.day > 9 ? result.day.toString() : "0${result.day}";
                                                    setState(() { endDateController.text = "$year-$month-$day"; });
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height : 8),
                                      // 측정 상황
                                      SizedBox(
                                        width : double.infinity,
                                        child : Text("측정 상황", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                                      ),
                                      SizedBox(height : 8),
                                      Expanded(
                                        child: Container(
                                          padding : const EdgeInsets.only(bottom : 8),
                                          width : double.infinity,
                                          child : LayoutBuilder(
                                              builder : (context, size) {
                                                final width = size.maxWidth;
                                                return DropdownMenu<String>(
                                                  hintText : "(필수) 선택해주세요",
                                                  width : width,
                                                  menuHeight : 250,
                                                  controller : contextController,
                                                  onSelected : (value) { setState(() { print(value); selectContext = value; }); },
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
                                                  dropdownMenuEntries : contextList.isEmpty ? [] : contextList,
                                                );
                                              }
                                          ),
                                        ),
                                      ),
                                      SizedBox(height : 8),
                                      // 정렬 방식(날짜 기준)
                                      SizedBox(
                                        width : double.infinity,
                                        child : Text("정렬 방식 (날짜 기준)", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                                      ),
                                      SizedBox(height : 8),
                                      Expanded(
                                        child: Container(
                                          padding : const EdgeInsets.only(bottom : 8),
                                          width : double.infinity * 0.47,
                                          child : LayoutBuilder(
                                              builder : (context, size) {
                                                final width = size.maxWidth;
                                                return DropdownMenu<String>(
                                                  hintText : "(필수) 선택해주세요",
                                                  width : width,
                                                  menuHeight : 250,
                                                  controller : sortingController,
                                                  onSelected : (value) { setState(() { print(value); selectSorting = value; }); },
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
                                                  dropdownMenuEntries : sortingList.isEmpty ? [] : sortingList,
                                                );
                                              }
                                          ),
                                        ),
                                      ),
                                      SizedBox(height : 8),
                                      // 조회하기 버튼
                                      SizedBox(
                                        width : double.infinity,
                                        child : ElevatedButton(
                                          onPressed : () async {
                                            setState(() {
                                              _isFilter = true;
                                              page = 0;
                                              item.clear();
                                            });
                                            readData();
                                            Navigator.pop(context);
                                          },
                                          child : Text("조회하기"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                          // if(token != null) {
                          //   final result = await Navigator.push(context, MaterialPageRoute(builder : (context) => CreateSugarPage()));
                          //   if(result != null) {
                          //     // setState(() { refresh(); });
                          //     setState(() { item.insert(0, result); });
                          //   }
                          // } else {
                          //   Navigator.push(context, MaterialPageRoute(builder : (context) => LoginPage()));
                          // }
                        },
                        child : Text("조건 조회"),
                      ),
                    ),
                    /** 추가하기 버튼 */
                    Container(
                      margin : const EdgeInsets.symmetric(horizontal : 16.0, vertical : 8.0),
                      // width : double.infinity,
                      child : ElevatedButton(
                        onPressed : () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString("token");
                          if(token != null) {
                            final result = await Navigator.push(context, MaterialPageRoute(builder : (context) => CreateSugarPage()));
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
                  ],
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
        /** 정보 카드 */
        Expanded(
          child : Container(
            padding : const EdgeInsets.symmetric(horizontal : 16.0, vertical : 8.0),
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
                                          Icon(Icons.water_drop, color : AppColors.mainColor, size : 32),
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
                                                    // Expanded(child : SizedBox(width : double.infinity)),
                                                    Text(" | ", style : TextStyle(fontSize : 16)),
                                                    Text(info["measurementContextLabel"], style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                                                  ],
                                                ),
                                                SizedBox(height : 8),
                                                Text("수치 : ${info['bloodSugarValue']} mg/dL", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
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
                                                              builder : (context) => UpdateSugarPage(
                                                                bloodSugarId : info["bloodSugarId"],
                                                                bloodSugarValue : info["bloodSugarValue"],
                                                                date : date,
                                                                time : time,
                                                                measurementContextId : info["measurementContextId"],
                                                                measurementContextLabel : info["measurementContextLabel"]
                                                              ),
                                                            ),
                                                          );
                                                          if(result != null) {
                                                            if(info["bloodSugarId"] == result["bloodSugarId"]) {
                                                              setState(() {
                                                                info["measuredAt"] = "${result["date"]}T${result["time"]}";
                                                                info["bloodSugarValue"] = result["bloodSugarValue"];
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
                                                              builder : (context) => DeleteSugarPage(bloodSugarId : info["bloodSugarId"])
                                                          );
                                                          if(result != null && result == info["bloodSugarId"]) {
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
