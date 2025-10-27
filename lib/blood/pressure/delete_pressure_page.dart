import 'package:bloodmate_app/modals/CustomAlertDialog.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeletePressurePage extends StatefulWidget {
  final int bloodPressureId;
  const DeletePressurePage({super.key, required this.bloodPressureId});

  @override
  State<DeletePressurePage> createState() => _DeletePressurePageState();
}

class _DeletePressurePageState extends State<DeletePressurePage> {

  Dio dio = Dio();
  String domain = ServerDomain.domain;

  // 데이터 삭제하기
  Future<void> deleteData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final response = await dio.delete("$domain/blood/pressure/${widget.bloodPressureId}", options : Options(headers : {"Authorization" : token}));
      if(response.statusCode == 200) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "삭제하기", content : "삭제에 성공했습니다.", isChange : false),
        );
        Navigator.pop(context, widget.bloodPressureId);
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 400) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "삭제하기", content : "삭제에 실패했습니다.", isChange : false),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor : Colors.white,
      shape : RoundedRectangleBorder(
        borderRadius : BorderRadius.circular(8.0),
      ),
      title : Text("혈당 삭제하기"),
      content : Column(
        crossAxisAlignment : CrossAxisAlignment.start,
        mainAxisSize : MainAxisSize.min,
        children : [
          Text("※ 정말 삭제하시겠습니까?", style : TextStyle(color : Colors.red, fontSize : 24, fontWeight : FontWeight.bold)),
          Text("※ 데이터가 영구 삭제되어 복구 할 수 없습니다.", style : TextStyle(color : Colors.red, fontSize : 24, fontWeight : FontWeight.bold)),
        ],
      ),
      actions : [
        ElevatedButton(
          style : ElevatedButton.styleFrom(
            backgroundColor : Colors.red,
            shape : RoundedRectangleBorder(borderRadius : BorderRadius.circular(8.0)),
          ),
          onPressed : deleteData,
          child : Text("삭제"),
        ),
        ElevatedButton(
          style : ElevatedButton.styleFrom(
            backgroundColor : Colors.grey,
            shape : RoundedRectangleBorder(borderRadius : BorderRadius.circular(8.0)),
          ),
          onPressed : () {
            Navigator.pop(context, false);
          },
          child : Text("취소"),
        ),
      ],
    );
  }
}
