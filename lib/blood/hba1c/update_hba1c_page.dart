import 'package:bloodmate_app/modals/CustomAlertDialog.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateHba1cPage extends StatefulWidget {
  final String date;
  final String time;
  final double value;
  final String next;
  final int hba1cId;
  const UpdateHba1cPage({
    super.key,
    required this.hba1cId,
    required this.date,
    required this.time,
    required this.value,
    required this.next
  });

  @override
  State<UpdateHba1cPage> createState() => _UpdateHba1cPageState();
}

class _UpdateHba1cPageState extends State<UpdateHba1cPage> {

  Dio dio = Dio();
  String domain = ServerDomain.domain;

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController nextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dateController.text = widget.date;
    timeController.text = widget.time;
    valueController.text = "${widget.value}";
    nextController.text = widget.next;
  }

  // 데이터 수정하기
  Future<void> updateData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final data = {
        "hba1cValue" : valueController.text,
        "measuredAt" : "${dateController.text}T${timeController.text}",
        "nextTestAt" : nextController.text,
      };
      final response = await dio.put("$domain/blood/hba1c/${widget.hba1cId}", data : data, options : Options(headers : {"Authorization" : token}));
      if(response.statusCode == 200) {
        await showDialog(
            context : context,
            builder : (context) => CustomAlertDialog(context : context, title : "수정하기", content : "수정에 성공했습니다.", isChange : false)
        );
        final result = {
          "hba1cId" : widget.hba1cId,
          "date" : dateController.text,
          "time" : timeController.text,
          "value" : valueController.text,
          "next" : nextController.text,
        };
        Navigator.pop(context, result);
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 400) {
        await showDialog(
            context : context,
            builder : (context) => CustomAlertDialog(context : context, title : "수정하기", content : "수정에 실패했습니다.", isChange : false)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor : Colors.white,
      appBar : AppBar(
        title : Text("당화혈색소 수정하기"),
        backgroundColor : Colors.white,
      ),
      body : SafeArea(
        child : Container(
          padding : const EdgeInsets.symmetric(horizontal : 32.0, vertical : 16.0),
          width : double.infinity,
          child : Column(
            crossAxisAlignment : CrossAxisAlignment.start,
            children : [
              // 측정일
              Container(
                padding : const EdgeInsets.only(bottom : 8),
                child : Text("측정일", style : TextStyle(fontSize : 16)),
              ),
              Container(
                padding : const EdgeInsets.only(bottom : 8),
                child : TextField(
                  controller : dateController,
                  readOnly : true,
                  decoration : InputDecoration(
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
                      setState(() { dateController.text = "$year-$month-$day"; });
                    }
                  },
                ),
              ),

              // 측정 시간
              Container(
                padding : const EdgeInsets.only(bottom : 8),
                child : Text("측정 시간", style : TextStyle(fontSize : 16)),
              ),
              Container(
                padding : const EdgeInsets.only(bottom : 8),
                child : TextField(
                  controller : timeController,
                  readOnly : true,
                  decoration : InputDecoration(
                    enabledBorder : OutlineInputBorder(
                      borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                    ),
                    focusedBorder : OutlineInputBorder(
                      borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                    ),
                  ),
                  onTap : () async {
                    final result = await showTimePicker(
                      context : context,
                      initialTime : TimeOfDay.now(),
                      barrierDismissible : false,
                    );
                    String hour, minute;
                    if(result != null) {
                      hour = result.hour > 9 ? result.hour.toString() : "0${result.hour}";
                      minute = result.minute > 9 ? result.minute.toString() : "0${result.minute}";
                      setState(() { timeController.text = "$hour:$minute"; });
                    }
                  },
                ),
              ),

              // 당화혈색소 수치
              Container(
                padding : const EdgeInsets.only(bottom : 8),
                child : Text("당화혈색소 수치", style : TextStyle(fontSize : 16)),
              ),
              Container(
                padding : const EdgeInsets.only(bottom : 8),
                child : TextField(
                  controller : valueController,
                  keyboardType : TextInputType.number,
                  decoration : InputDecoration(
                    enabledBorder : OutlineInputBorder(
                      borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                    ),
                    focusedBorder : OutlineInputBorder(
                      borderSide : BorderSide(color : AppColors.mainColor, width : 2),
                    ),
                    suffixIcon : Icon(Icons.percent, color : AppColors.mainColor),
                  ),
                ),
              ),

              // 다음 검사 예정일
              Container(
                padding : const EdgeInsets.only(bottom : 8),
                child : Text("다음 검사 예정일", style : TextStyle(fontSize : 16)),
              ),
              Container(
                padding : const EdgeInsets.only(bottom : 8),
                child : TextField(
                  controller : nextController,
                  readOnly : true,
                  decoration : InputDecoration(
                    enabledBorder : OutlineInputBorder(
                      borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                    ),
                    focusedBorder : OutlineInputBorder(
                      borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                    ),
                  ),
                  onTap : () async {
                    final resultDate = await showDatePicker(
                      context : context,
                      initialDate : DateTime.now(),
                      firstDate : DateTime(1900),
                      lastDate : DateTime(2100),
                      barrierDismissible : false,
                    );
                    String year, month, day;
                    if(resultDate != null) {
                      year = resultDate.year > 9 ? resultDate.year.toString() : "0${resultDate.year}";
                      month = resultDate.month > 9 ? resultDate.month.toString() : "0${resultDate.month}";
                      day = resultDate.day > 9 ? resultDate.day.toString() : "0${resultDate.day}";
                      setState(() { nextController.text = "$year-$month-$day"; });
                    }
                    final resultTime = await showTimePicker(
                      context : context,
                      initialTime : TimeOfDay.now(),
                      barrierDismissible : false,
                    );
                    String hour, minute;
                    if(resultTime != null) {
                      hour = resultTime.hour > 9 ? resultTime.hour.toString() : "0${resultTime.hour}";
                      minute = resultTime.minute > 9 ? resultTime.minute.toString() : "0${resultTime.minute}";
                      setState(() { nextController.text += "T$hour:$minute"; });
                    }
                  },
                ),
              ),

              // 작성하기 버튼
              Container(
                padding : const EdgeInsets.only(top : 8),
                width : double.infinity,
                child : ElevatedButton(
                  onPressed : updateData,
                  child : Text("수정하기"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
