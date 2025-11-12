import 'package:bloodmate_app/modals/CustomAlertDialog.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  Dio dio = Dio();

  String domain = ServerDomain.domain;

  bool _visibility1 = true;
  bool _visibility2 = true;
  bool _checkPhone = false;
  bool _checkNickname = false;
  bool _checkLoginId = false;

  TextEditingController userName = TextEditingController();
  TextEditingController userBirthDate = TextEditingController();
  TextEditingController userEmail = TextEditingController();
  TextEditingController userPhone = TextEditingController();
  TextEditingController userNickname = TextEditingController();
  TextEditingController userLoginId = TextEditingController();
  TextEditingController userPassword = TextEditingController();
  TextEditingController checkPassword = TextEditingController();

  Widget customTextField({
    required String title,
    required TextEditingController? controller,
    required String hintText,
    required Icon prefixIcon,
    required IconButton? suffixIcon,
    required bool? visibility,
    required List<TextInputFormatter> phoneFormatter,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment : CrossAxisAlignment.start,
      children : [
        TextField(
          controller : controller,
          obscureText : obscureText,
          inputFormatters : phoneFormatter,
          keyboardType : keyboardType,
          decoration : InputDecoration(
            hintText : hintText,
            contentPadding : EdgeInsets.symmetric(vertical : 8, horizontal : 8),
            enabledBorder : OutlineInputBorder(
              borderRadius : BorderRadius.circular(8.0),
              borderSide : BorderSide(
                color : AppColors.mainColor,
                width : 1,
              ),
            ),
            focusedBorder : OutlineInputBorder(
              borderRadius : BorderRadius.circular(8.0),
              borderSide : BorderSide(
                color : AppColors.mainColor,
                width : 2,
              ),
            ),
            prefixIcon : prefixIcon,
            suffixIcon : suffixIcon,
          ),
        ),
      ],
    );
  }

  // 회원가입
  Future<String> signup() async {
    if(!_checkPhone) {
      return "전화번호";
    } else if(!_checkNickname) {
      return "닉네임";
    } else if(!_checkLoginId) {
      return "아이디";
    } else if(!(userPassword.text == checkPassword.text)) {
      return "비밀번호";
    } else {
      try {
        final data = {
          "userLoginId" : userLoginId.text, "userPassword" : userPassword.text,
          "userNickname" : userNickname.text, "userName" : userName.text,
          "userBirthDate" : userBirthDate.text, "userPhone" : userPhone.text,
          "userEmail" : userEmail.text, "userRole" : 0,
        };
        final response = await dio.post("$domain/user/signup", data : data);
        if(response.statusCode == 201 && response.data) {
          await showDialog(
            context : context,
            builder : (context) => CustomAlertDialog(
              context : context,
              title : "회원가입 성공",
              content : "회원가입에 성공했습니다.",
              isChange : true,
            ),
          );
          return "정상 처리";
        } else {
          return "실패";
        }
      } on DioException catch(e) {
        if(e.response?.statusCode == 400) {
          await showDialog(
            context : context,
            builder : (context) => CustomAlertDialog(
              context : context,
              title : "회원가입 실패",
              content : "회원가입에 실패했습니다.",
              isChange : false,
            ),
          );
        }
        return "오류";
      }
    }
  }

  // 전화번호 확인
  Future<void> checkUserPhone() async {
    try {
      final response = await dio.get("$domain/user/check-phone", queryParameters : {"userPhone" : userPhone.text});
      String content = "";
      if(response.data) {
        content = "이미 가입된 전화번호입니다.";
      } else {
        content = "가입 가능한 전화번호입니다.";
        setState(() { _checkPhone = true; });
      }
      await showDialog(
        context : context,
        builder : (context) => CustomAlertDialog(
          context : context,
          title : "전화번호 중복 확인",
          content : content,
          isChange : false,
        ),
      );
    } catch(e) {
      await showDialog(
        context : context,
        builder : (context) => CustomAlertDialog(
          context : context,
          title : "전화번호 중복 확인",
          content : "오류입니다.",
          isChange : false,
        ),
      );
    }
  }
  
  // 닉네임 확인
  Future<void> checkUserNickname() async {
    try {
      final response = await dio.get("$domain/user/check-nickname", queryParameters : {"userNickname" : userNickname.text});
      String content = "";
      if(response.data) {
        content = "이미 존재하는 닉네임입니다.";
      } else {
        content = "가입 가능한 닉네임입니다.";
        setState(() { _checkNickname = true; });
      }
      await showDialog(
        context : context,
        builder : (context) => CustomAlertDialog(
          context : context,
          title : "닉네임 중복 확인",
          content : content,
          isChange : false,
        ),
      );
    } catch(e) {
      await showDialog(
        context : context,
        builder : (context) => CustomAlertDialog(
          context : context,
          title : "닉네임 중복 확인",
          content : "오류입니다.",
          isChange : false,
        ),
      );
    }
  }

  // 아이디 확인
  Future<void> checkUserLoginId() async {
    try {
      final response = await dio.get("$domain/user/check-login-id", queryParameters : {"userLoginId" : userLoginId.text});
      String content = "";
      if(response.data) {
        content = "이미 존재하는 아이디입니다.";
      } else {
        content = "가입 가능한 아이디입니다.";
        setState(() { _checkLoginId = true; });
      }
      await showDialog(
        context : context,
        builder : (context) => CustomAlertDialog(
          context : context,
          title : "아이디 중복 확인",
          content : content,
          isChange : false,
        ),
      );
    } catch(e) {
      await showDialog(
        context : context,
        builder : (context) => CustomAlertDialog(
          context : context,
          title : "아이디 중복 확인",
          content : "오류입니다.",
          isChange : false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar : AppBar(
        title : Text("회원가입"),
        backgroundColor : Colors.white,
      ),
      body : SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding : const EdgeInsets.symmetric(horizontal : 16.0, vertical : 8.0),
            color : Colors.white,
            width : double.infinity,
            child : Column(
              crossAxisAlignment : CrossAxisAlignment.start,
              children : [
                // 이름
                Text("이름", style : TextStyle(fontSize : 16)),
                SizedBox(height : 8.0),
                customTextField(
                  title : "이름",
                  controller : userName,
                  hintText : "이름",
                  prefixIcon : Icon(
                    Icons.person,
                    color : AppColors.mainColor,
                  ),
                  suffixIcon : null,
                  visibility : null,
                  phoneFormatter : [],
                ),
                SizedBox(height : 16),
                // 생년월일
                Text("생년월일", style : TextStyle(fontSize : 16)),
                SizedBox(height : 8.0),
                customTextField(
                  title : "생년월일",
                  controller : userBirthDate,
                  hintText : "생년월일(XXXX-XX-XX)",
                  keyboardType : TextInputType.number,
                  prefixIcon : Icon(
                    Icons.calendar_month,
                    color : AppColors.mainColor,
                  ),
                  suffixIcon : null,
                  visibility : null,
                  phoneFormatter : [BirthFormatter()],
                ),
                SizedBox(height : 16),
                // 이메일
                Text("이메일", style : TextStyle(fontSize : 16)),
                SizedBox(height : 8.0),
                customTextField(
                  title : "이메일",
                  controller : userEmail,
                  hintText : "이메일",
                  prefixIcon : Icon(
                    Icons.email,
                    color : AppColors.mainColor,
                  ),
                  suffixIcon : null,
                  visibility : null,
                  phoneFormatter : [],
                ),
                SizedBox(height : 16),
                // 전화번호
                Text("전화번호", style : TextStyle(fontSize : 16)),
                SizedBox(height : 8.0),
                Row(
                  crossAxisAlignment : CrossAxisAlignment.center,
                  children : [
                    Expanded(
                      child : SizedBox(
                        height : 48,
                        child: customTextField(
                          title : "전화번호",
                          controller : userPhone,
                          hintText : "전화번호(010-XXXX-XXXX)",
                          keyboardType : TextInputType.number,
                          prefixIcon : Icon(
                            Icons.smartphone,
                            color : AppColors.mainColor,
                          ),
                          suffixIcon : null,
                          visibility : null,
                          phoneFormatter : [PhoneHyphenFormatter()],
                        ),
                      ),
                    ),
                    SizedBox(width : 20),
                    SizedBox(
                      child : ElevatedButton(
                        onPressed : checkUserPhone,
                        child : Text("확인"),
                      ),
                    ),
                  ],
                ),
                SizedBox(height : 16),
                // 닉네임
                Text("닉네임", style : TextStyle(fontSize : 16)),
                SizedBox(height : 8.0),
                Row(
                  crossAxisAlignment : CrossAxisAlignment.center,
                  children : [
                    Expanded(
                      child : SizedBox(
                        height : 48,
                        child: customTextField(
                          title : "닉네임",
                          controller : userNickname,
                          hintText : "닉네임",
                          prefixIcon : Icon(
                            Icons.person,
                            color : AppColors.mainColor,
                          ),
                          suffixIcon : null,
                          visibility : null,
                          phoneFormatter : [],
                        ),
                      ),
                    ),
                    SizedBox(width : 20),
                    SizedBox(
                      child : ElevatedButton(
                        onPressed : checkUserNickname,
                        child : Text("확인"),
                      ),
                    ),
                  ],
                ),
                SizedBox(height : 16),
                // 아이디
                Text("아이디", style : TextStyle(fontSize : 16)),
                SizedBox(height : 8.0),
                Row(
                  crossAxisAlignment : CrossAxisAlignment.center,
                  children : [
                    Expanded(
                      child : SizedBox(
                        height : 48,
                        child: customTextField(
                          title : "아이디",
                          controller : userLoginId,
                          hintText : "아이디",
                          prefixIcon : Icon(
                            Icons.person,
                            color : AppColors.mainColor,
                          ),
                          suffixIcon : null,
                          visibility : null,
                          phoneFormatter : [],
                        ),
                      ),
                    ),
                    SizedBox(width : 20),
                    SizedBox(
                      child : ElevatedButton(
                        onPressed : checkUserLoginId,
                        child : Text("확인"),
                      ),
                    ),
                  ],
                ),
                SizedBox(height : 16),
                // 비밀번호
                Text("비밀번호", style : TextStyle(fontSize : 16)),
                SizedBox(height : 8.0),
                customTextField(
                  title : "비밀번호",
                  controller : userPassword,
                  hintText : "비밀번호",
                  prefixIcon : Icon(
                    Icons.key,
                    color : AppColors.mainColor,
                  ),
                  suffixIcon : IconButton(
                    onPressed : () { setState(() { _visibility1 = !_visibility1; }); },
                    icon : Icon(_visibility1 ? Icons.visibility : Icons.visibility_off, color : AppColors.mainColor),
                  ),
                  visibility : null,
                  obscureText :  _visibility1,
                  phoneFormatter : [],
                ),
                SizedBox(height : 16),
                // 비밀번호 확인
                Text("비밀번호 확인", style : TextStyle(fontSize : 16)),
                SizedBox(height : 8.0),
                customTextField(
                  title : "비밀번호 확인",
                  controller : checkPassword,
                  hintText : "비밀번호 확인",
                  prefixIcon : Icon(
                    Icons.key,
                    color : AppColors.mainColor,
                  ),
                  suffixIcon : IconButton(
                    onPressed : () { setState(() { _visibility2 = !_visibility2; }); },
                    icon : Icon(_visibility2 ? Icons.visibility : Icons.visibility_off, color : AppColors.mainColor),
                  ),
                  visibility : null,
                  obscureText :  _visibility2,
                  phoneFormatter : [],
                ),
                SizedBox(height : 16),
                // 회원가입 버튼
                SizedBox(
                  width : double.infinity,
                  child : ElevatedButton(
                    onPressed : () async {
                      String result = await signup();
                      if(result == "전화번호" || result == "닉네임" || result == "아이디" || result == "비밀번호") {
                        await showDialog(
                          context : context,
                          builder : (context) => CustomAlertDialog(
                            context : context,
                            title : "회원가입 실패",
                            content : "$result의 문제로 회원가입에 실패했습니다.",
                            isChange : false,
                          ),
                        );
                      }
                    },
                    child : Text("회원가입"),
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

/// 전화번호 입력 정규화
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

// 생년월일 입력 정규화
class BirthFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    var buf = StringBuffer();

    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 4 || i == 6) buf.write('-');
      buf.write(digits[i]);
    }

    final result = buf.toString();
    return TextEditingValue(
      text : result,
      selection : TextSelection.collapsed(offset: result.length),
    );
  }
}
