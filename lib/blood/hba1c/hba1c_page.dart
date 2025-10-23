import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
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

  // 페이지 인덱스
  int page = 1;
  // 페이지 크기
  int size = 5;
  // 정렬 상태
  String sorting = "DESC";
  // 전송받은 데이터
  List<dynamic> item = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readData();
  }

  // 당화혈색소 데이터 불러오기
  Future<void> readData() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      final response = await dio.get(
        "$domain/blood/hba1c",
        options : Options(headers : {"Authorization" : token}),
        queryParameters : {"page" : page, "size" : size, "sorting" : sorting},
      );
      print(response.data);
      if(response.statusCode == 200) {
        item.addAll(response.data["content"]);
      }
    } on DioException catch(e) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding : const EdgeInsets.symmetric(horizontal : 32.0, vertical : 16.0),
      width : double.infinity,
      child: Column(
        crossAxisAlignment : CrossAxisAlignment.start,
        children : [
          Expanded(
            child: ListView.builder(
              controller : null,
              itemCount : item.length,
              itemBuilder : (context, index) {

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
                      padding : const EdgeInsets.all(8.0),
                      child : Column(
                        crossAxisAlignment : CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding : const EdgeInsets.only(left : 16.0),
                            child: Text("$date : $time", style : TextStyle(fontSize : 16)),
                          ),
                          ListTile(
                            title : Text("수치 : ${info['hba1cValue']}"),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

}