import 'package:bloodmate_app/modals/CustomAlertDialog.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:bloodmate_app/user/user_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneChangePage extends StatefulWidget {

  final String phone;

  const PhoneChangePage({super.key, required this.phone});

  @override
  State<PhoneChangePage> createState() => _PhoneChangePageState();
}

class _PhoneChangePageState extends State<PhoneChangePage> {

  Dio dio = Dio();
  final String domain = ServerDomain.domain;
  bool _visibility = true;

  TextEditingController oldPhoneController = TextEditingController();
  TextEditingController newPhoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      oldPhoneController.text = widget.phone;
    });
  }

  // 전화번호 수정
  Future<void> changePhone() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final data = {"phone" : oldPhoneController.text, "newPhone" : newPhoneController.text, "password" : passwordController.text};
      final response = await dio.patch("$domain/user/information/phone", data : data, options : Options(headers : {"Authorization" : token}));
      if(response.statusCode == 200) {
        await showDialog(
            context : context,
            builder : (context) => CustomAlertDialog(
              context : context,
              title : "변경 성공",
              content : "전화번호가 성공적으로 변경되었습니다.",
              isChange : true,
            )
        );
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 400) {
        await showDialog(
            context : context,
            builder : (context) => CustomAlertDialog(
              context : context,
              title : "변경 실패",
              content : "전화번호 변경에 실패했습니다.",
              isChange : false,
            )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor : Colors.white,
      appBar : AppBar(
        title : Text("전화번호 수정"),
        backgroundColor : Colors.white,
      ),
      body : Container(
        padding : const EdgeInsets.symmetric(vertical : 16.0, horizontal : 16.0),
        width : double.infinity,
        child : Column(
          crossAxisAlignment : CrossAxisAlignment.start,
          children : [
            Text("현재 전화번호", style : TextStyle(fontSize : 20)),
            SizedBox(height : 16),
            // 현재 전화번호
            SizedBox(
              // height : 40,
              child: TextField(
                controller : oldPhoneController,
                readOnly : true,
                decoration : InputDecoration(
                  border : OutlineInputBorder(
                      borderSide : BorderSide(color : AppColors.mainColor, width : 1)
                  ),
                  focusedBorder : OutlineInputBorder(
                      borderSide : BorderSide(color : AppColors.mainColor, width : 1)
                  ),
                  prefixIcon : Icon(Icons.email, color : AppColors.mainColor),
                ),
              ),
            ),
            SizedBox(height : 16),
            Text("변경할 전화번호", style : TextStyle(fontSize : 20)),
            SizedBox(height : 16),
            // 변경할 전화번호
            SizedBox(
              // height : 40,
              child: TextField(
                controller : newPhoneController,
                keyboardType : TextInputType.number,
                inputFormatters: [PhoneHyphenFormatter()],
                decoration : InputDecoration(
                  labelText : "숫자만 입력",
                  enabledBorder : OutlineInputBorder(
                      borderSide : BorderSide(color : AppColors.mainColor, width : 1)
                  ),
                  focusedBorder : OutlineInputBorder(
                      borderSide : BorderSide(color : AppColors.mainColor, width : 2)
                  ),
                  prefixIcon : Icon(Icons.email, color : AppColors.mainColor),
                ),
              ),
            ),
            SizedBox(height : 16),
            Text("비밀번호", style : TextStyle(fontSize : 20)),
            SizedBox(height : 16),
            // 비밀번호
            SizedBox(
              // height : 40,
              child: TextField(
                controller : passwordController,
                obscureText : _visibility,
                decoration : InputDecoration(
                  enabledBorder : OutlineInputBorder(
                      borderSide : BorderSide(color : AppColors.mainColor, width : 1)
                  ),
                  focusedBorder : OutlineInputBorder(
                      borderSide : BorderSide(color : AppColors.mainColor, width : 2)
                  ),
                  prefixIcon : Icon(Icons.key, color : AppColors.mainColor),
                  suffixIcon : IconButton(
                    onPressed : () {
                      setState(() {
                        _visibility = !_visibility;
                      });
                    },
                    icon : Icon(_visibility ? Icons.visibility : Icons.visibility_off, color : AppColors.mainColor),
                  ),
                ),

              ),
            ),
            SizedBox(height : 16),
            SizedBox(
              width : double.infinity,
              child : ElevatedButton(
                style : ElevatedButton.styleFrom(
                  backgroundColor : AppColors.mainColor,
                  shape : RoundedRectangleBorder(
                    borderRadius : BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: changePhone,
                child: Text("변경하기", style : TextStyle(color : Colors.white, fontSize : 16, fontWeight : FontWeight.bold)),
              ),
            ),
            SizedBox(height : 16),
          ],
        ),
      ),
    );
  }
}

// 전화번호 입력 정규화
class PhoneHyphenFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    var buf = StringBuffer();

    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 3 || i == 7) buf.write('-');
      buf.write(digits[i]);
    }

    final result = buf.toString();
    return TextEditingValue(
      text : result,
      selection : TextSelection.collapsed(offset: result.length),
    );
  }
}
