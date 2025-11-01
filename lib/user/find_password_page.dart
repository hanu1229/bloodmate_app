import 'package:bloodmate_app/modals/CustomAlertDialog.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FindPasswordPage extends StatefulWidget {
  const FindPasswordPage({super.key});

  @override
  State<FindPasswordPage> createState() => _FindPasswordPageState();
}

class _FindPasswordPageState extends State<FindPasswordPage> {

  Dio dio = Dio();
  String domain = ServerDomain.domain;
  bool _isCheck = false;
  bool _showPassword = true;
  bool _showCheckPassword = true;
  String resetToken = "";

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController checkPasswordController = TextEditingController();

  // 인증번호 발송
  Future<void> getCode() async {
    try {
      final data = {
        "userLoginId" : idController.text,
        "userName" : nameController.text,
        "userPhone" : phoneController.text,
      };
      final response = await dio.post("$domain/user/verification-code", data : data);
      if(response.statusCode == 201) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "인증번호 발송", content : "인증번호가 발송되었습니다.", isChange : false),
        );
        setState(() { codeController.text = response.data; });
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 404) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "인증번호 발송", content : "${e.response?.data}", isChange : false),
        );
      }
    }
  }

  // 인증번호 확인
  Future<void> sendCode() async {
    try {
      final data = {
        "userLoginId" : idController.text,
        "userName" : nameController.text,
        "userPhone" : phoneController.text,
        "verificationCode" : codeController.text,
      };
      final response = await dio.post("$domain/user/check-code", data : data);
      if(response.statusCode == 200) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "인증번호 확인", content : "인증에 성공했습니다.", isChange : false),
        );
        setState(() { codeController.text = response.data; });
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 404 && e.response?.statusCode == 400) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "인증번호 확인", content : "인증에 실패했습니다.", isChange : false),
        );
      }
    }
  }

  // 비밀번호 찾기
  Future<void> findPassword() async {
    try {
      final data = {
        "userLoginId" : idController.text,
        "userName" : nameController.text,
        "userPhone" : phoneController.text,
        "verificationCode" : codeController.text,
      };
      final response = await dio.post("$domain/user/search", data : data);
      if(response.statusCode == 201) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "비밀번호 찾기", content : "새로운 비밀번호를 설정하세요.", isChange : false),
        );
        setState(() {
          _isCheck = true;
          resetToken = response.data;
        });
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 404) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "비밀번호 찾기", content : "${e.response?.data}", isChange : false),
        );
      }
    }
  }

  // 비밀번호 재설정
  Future<void> resetPassword() async {
    try {
      if(passwordController.text != checkPasswordController.text) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "비밀번호 재설정", content : "비밀번호가 틀립니다.", isChange : false),
        );
        return;
      }
      final data = {
        "userLoginId" : idController.text,
        "userName" : nameController.text,
        "userPhone" : phoneController.text,
        "verificationCode" : codeController.text,
        "newPassword" : passwordController.text
      };
      final response = await dio.post("$domain/user/reset-password/$resetToken", data : data);
      if(response.statusCode == 200 && response.data == true) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "비밀번호 재설정", content : "비밀번호가 재설정 되었습니다.", isChange : false),
        );
        Navigator.pop(context);
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 404) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "비밀번호 재설정", content : "비밀번호가 틀립니다.", isChange : false),
        );
      }
    }
  }

  // 비밀번호 재설정 페이지 위젯
  Widget resetPasswordWidget() {
    return Column(
      children : [
        // 새로운 비밀번호
        Padding(
          padding : const EdgeInsets.only(bottom : 8),
          child : Column(
            crossAxisAlignment : CrossAxisAlignment.start,
            children : [
              Text("새로운 비밀번호", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
              SizedBox(height : 8),
              TextField(
                controller : passwordController,
                obscureText : _showPassword,
                decoration : InputDecoration(
                  hintText : "새로운 비밀번호",
                  enabledBorder : OutlineInputBorder(
                    borderRadius : BorderRadius.circular(8.0),
                    borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                  ),
                  focusedBorder : OutlineInputBorder(
                    borderRadius : BorderRadius.circular(8.0),
                    borderSide : BorderSide(color : AppColors.mainColor, width : 2),
                  ),
                  suffixIcon : IconButton(
                    onPressed : () { setState(() { _showPassword = !_showPassword; }); },
                    icon : Icon(_showPassword ? Icons.visibility : Icons.visibility_off, color : AppColors.mainColor),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 새로운 비밀번호 확인
        Padding(
          padding : const EdgeInsets.only(bottom : 8),
          child : Column(
            crossAxisAlignment : CrossAxisAlignment.start,
            children : [
              Text("새로운 비밀번호 확인", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
              SizedBox(height : 8),
              TextField(
                controller : checkPasswordController,
                obscureText : _showCheckPassword,
                decoration : InputDecoration(
                  hintText : "새로운 비밀번호 확인",
                  enabledBorder : OutlineInputBorder(
                    borderRadius : BorderRadius.circular(8.0),
                    borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                  ),
                  focusedBorder : OutlineInputBorder(
                    borderRadius : BorderRadius.circular(8.0),
                    borderSide : BorderSide(color : AppColors.mainColor, width : 2),
                  ),
                  suffixIcon : IconButton(
                    onPressed : () { setState(() { _showCheckPassword = !_showCheckPassword; }); },
                    icon : Icon(_showCheckPassword ? Icons.visibility : Icons.visibility_off, color : AppColors.mainColor),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 비밀번호 변경
        Container(
          padding : const EdgeInsets.only(top : 8, bottom : 8),
          width : double.infinity,
          child : ElevatedButton(
            onPressed : resetPassword,
            child : Text("비밀번호 변경"),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        title : Text("비밀번호 찾기"),
      ),
      body : SafeArea(
        child : Container(
          padding : const EdgeInsets.symmetric(horizontal : 32, vertical : 8),
          width : double.infinity,
          child : _isCheck ? resetPasswordWidget() : Column(
            crossAxisAlignment : CrossAxisAlignment.start,
            children : [
              // 아이디
              Padding(
                padding : const EdgeInsets.only(bottom : 8),
                child: Column(
                  crossAxisAlignment : CrossAxisAlignment.start,
                  children: [
                    Text("아이디", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                    SizedBox(height : 8),
                    TextField(
                      controller : idController,
                      decoration : InputDecoration(
                        hintText : "아이디",
                        enabledBorder : OutlineInputBorder(
                          borderRadius : BorderRadius.circular(8.0),
                          borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                        ),
                        focusedBorder : OutlineInputBorder(
                          borderRadius : BorderRadius.circular(8.0),
                          borderSide : BorderSide(color : AppColors.mainColor, width : 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 이름
              Padding(
                padding : const EdgeInsets.only(bottom : 8),
                child: Column(
                  crossAxisAlignment : CrossAxisAlignment.start,
                  children: [
                    Text("이름", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                    SizedBox(height : 8),
                    TextField(
                      controller : nameController,
                      decoration : InputDecoration(
                        hintText : "이름",
                        enabledBorder : OutlineInputBorder(
                          borderRadius : BorderRadius.circular(8.0),
                          borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                        ),
                        focusedBorder : OutlineInputBorder(
                          borderRadius : BorderRadius.circular(8.0),
                          borderSide : BorderSide(color : AppColors.mainColor, width : 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 전화번호
              Padding(
                padding : const EdgeInsets.only(bottom : 8),
                child : Column(
                  crossAxisAlignment : CrossAxisAlignment.start,
                  children : [
                    Text("전화번호", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                    SizedBox(height : 8),
                    Row(
                      children: [
                        Expanded(
                          child : TextField(
                            controller : phoneController,
                            keyboardType : TextInputType.phone,
                            inputFormatters : [PhoneHyphenFormatter()],
                            decoration : InputDecoration(
                              hintText : "010-XXXX-XXXX",
                              enabledBorder : OutlineInputBorder(
                                borderRadius : BorderRadius.circular(8.0),
                                borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                              ),
                              focusedBorder : OutlineInputBorder(
                                borderRadius : BorderRadius.circular(8.0),
                                borderSide : BorderSide(color : AppColors.mainColor, width : 2),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding : const EdgeInsets.only(left : 16),
                          height : 56,
                          child : ElevatedButton(
                            onPressed : getCode,
                            child : Text("인증번호 발송"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 인증번호
              Padding(
                padding : const EdgeInsets.only(bottom : 8),
                child : Column(
                  crossAxisAlignment : CrossAxisAlignment.start,
                  children : [
                    Text("인증번호", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                    SizedBox(height : 8),
                    Row(
                      children : [
                        Expanded(
                          child : TextField(
                            controller : codeController,
                            keyboardType : TextInputType.number,
                            inputFormatters : [codeFormatter()],
                            decoration : InputDecoration(
                              hintText : "인증번호",
                              enabledBorder : OutlineInputBorder(
                                borderRadius : BorderRadius.circular(8.0),
                                borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                              ),
                              focusedBorder : OutlineInputBorder(
                                borderRadius : BorderRadius.circular(8.0),
                                borderSide : BorderSide(color : AppColors.mainColor, width : 2),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding : const EdgeInsets.only(left : 16),
                          height : 56,
                          child : ElevatedButton(
                            onPressed : sendCode,
                            child : Text("확인"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 비밀번호 찾기
              Container(
                padding : const EdgeInsets.only(top : 8, bottom : 8),
                width : double.infinity,
                child : ElevatedButton(
                  onPressed : findPassword,
                  child : Text("비밀번호 찾기"),
                ),
              ),
            ],
          ),
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

// 전화번호 입력 정규화
class codeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    return TextEditingValue(
      text : digits,
      selection : TextSelection.collapsed(offset: digits.length),
    );
  }
}
