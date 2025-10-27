import 'package:bloodmate_app/modals/CustomAlertDialog.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdatePressurePage extends StatefulWidget {
  final int bloodPressureId;
  final int bloodPressureSystolic;
  final int bloodPressureDiastolic;
  final int bloodPressurePulse;
  final int measurementContextId;
  final String measurementContextLabel;
  final String date;
  final String time;
  const UpdatePressurePage({
    super.key,
    required this.bloodPressureId,
    required this.bloodPressureSystolic,
    required this.bloodPressureDiastolic,
    required this.bloodPressurePulse,
    required this.measurementContextId,
    required this.measurementContextLabel,
    required this.date,
    required this.time,
  });

  @override
  State<UpdatePressurePage> createState() => _UpdatePressurePageState();
}

class _UpdatePressurePageState extends State<UpdatePressurePage> {
  Dio dio = Dio();
  String domain = ServerDomain.domain;

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController systolicController = TextEditingController();
  TextEditingController diastolicController = TextEditingController();
  TextEditingController pulseController = TextEditingController();
  TextEditingController contextController = TextEditingController();

  // 측정 상황 리스트
  List<DropdownMenuEntry<String>> contextList = [];
  // 선택한 측정 상황 값
  String? selectContext;

  // 측정 상황 불러오기
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


  // 혈당 데이터 수정하기
  Future<void> writeData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final data = {
        "bloodPressureSystolic" : int.parse(systolicController.text),
        "bloodPressureDiastolic" : int.parse(diastolicController.text),
        "bloodPressurePulse" : int.parse(pulseController.text),
        "measuredAt" : "${dateController.text}T${timeController.text}",
        "measurementContextId" : int.parse(selectContext.toString()),
      };
      final response = await dio.put("$domain/blood/pressure/${widget.bloodPressureId}", data : data, options : Options(headers : {"Authorization" : token}));
      if(response.statusCode == 200) {
        await showDialog(
            context : context,
            builder : (context) => CustomAlertDialog(context : context, title : "수정하기", content : "수정에 성공했습니다.", isChange : false)
        );
        final result = {
          "bloodPressureId" : widget.bloodPressureId,
          "bloodPressureSystolic" : int.parse(systolicController.text),
          "bloodPressureDiastolic" : int.parse(diastolicController.text),
          "bloodPressurePulse" : int.parse(pulseController.text),
          "date" : dateController.text,
          "time" : timeController.text,
          "measurementContextId" : selectContext,
          "measurementContextLabel" : contextController.text
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
  void initState() {
    // TODO: implement initState
    super.initState();
    dateController.text = widget.date;
    timeController.text = widget.time;
    contextController.text = widget.measurementContextLabel;
    systolicController.text = "${widget.bloodPressureSystolic}";
    diastolicController.text = "${widget.bloodPressureDiastolic}";
    pulseController.text =  "${widget.bloodPressurePulse}";
    selectContext = "${widget.measurementContextId}";
    readContext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor : Colors.white,
      appBar : AppBar(
        title : Text("혈압 수정하기"),
        backgroundColor : Colors.white,
      ),
      body : SafeArea(
        child : SingleChildScrollView(
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

                // 측정 상황
                Container(
                  padding : const EdgeInsets.only(bottom : 8),
                  child : Text("측정 상황", style : TextStyle(fontSize : 16)),
                ),
                Container(
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

                // 혈압 수축 수치
                Container(
                  padding : const EdgeInsets.only(bottom : 8),
                  child : Text("혈압 수축 수치", style : TextStyle(fontSize : 16)),
                ),
                Container(
                  padding : const EdgeInsets.only(bottom : 8),
                  child : TextField(
                    controller : systolicController,
                    keyboardType : TextInputType.numberWithOptions(decimal : true),
                    decoration : InputDecoration(
                      enabledBorder : OutlineInputBorder(
                        borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                      ),
                      focusedBorder : OutlineInputBorder(
                        borderSide : BorderSide(color : AppColors.mainColor, width : 2),
                      ),
                      suffixIcon : Padding(
                        padding : const EdgeInsets.only(right: 16),
                        child : Text("mmHg", style: TextStyle(color: AppColors.mainColor, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      suffixIconConstraints : BoxConstraints(minHeight : 0, minWidth : 0),
                    ),
                  ),
                ),

                // 혈압 이완 수치
                Container(
                  padding : const EdgeInsets.only(bottom : 8),
                  child : Text("혈압 이완 수치", style : TextStyle(fontSize : 16)),
                ),
                Container(
                  padding : const EdgeInsets.only(bottom : 8),
                  child : TextField(
                    controller : diastolicController,
                    keyboardType : TextInputType.numberWithOptions(decimal : true),
                    decoration : InputDecoration(
                      enabledBorder : OutlineInputBorder(
                        borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                      ),
                      focusedBorder : OutlineInputBorder(
                        borderSide : BorderSide(color : AppColors.mainColor, width : 2),
                      ),
                      suffixIcon : Padding(
                        padding : const EdgeInsets.only(right: 16),
                        child : Text("mmHg", style: TextStyle(color: AppColors.mainColor, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      suffixIconConstraints : BoxConstraints(minHeight : 0, minWidth : 0),
                    ),
                  ),
                ),

                // 심박수 수치
                Container(
                  padding : const EdgeInsets.only(bottom : 8),
                  child : Text("심박수", style : TextStyle(fontSize : 16)),
                ),
                Container(
                  padding : const EdgeInsets.only(bottom : 8),
                  child : TextField(
                    controller : pulseController,
                    keyboardType : TextInputType.numberWithOptions(decimal : true),
                    decoration : InputDecoration(
                      enabledBorder : OutlineInputBorder(
                        borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                      ),
                      focusedBorder : OutlineInputBorder(
                        borderSide : BorderSide(color : AppColors.mainColor, width : 2),
                      ),
                      suffixIcon : Padding(
                        padding : const EdgeInsets.only(right: 16),
                        child : Text("회", style: TextStyle(color: AppColors.mainColor, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      suffixIconConstraints : BoxConstraints(minHeight : 0, minWidth : 0),
                    ),
                  ),
                ),

                // 수정하기 버튼
                Container(
                  padding : const EdgeInsets.only(top : 8),
                  width : double.infinity,
                  child : ElevatedButton(
                    onPressed : writeData,
                    child : Text("수정하기"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
