import 'dart:convert';

import 'package:bloodmate_app/modals/CustomAlertDialog.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateBoardPage extends StatefulWidget {
  final int boardPostId;
  final String boardCategoryTitle;
  final String boardPostTitle;
  final String boardPostContent;
  const UpdateBoardPage({
    super.key,
    required this.boardPostId,
    required this.boardCategoryTitle,
    required this.boardPostTitle,
    required this.boardPostContent,
  });

  @override
  State<UpdateBoardPage> createState() => _UpdateBoardPageState();
}

class _UpdateBoardPageState extends State<UpdateBoardPage> {
  Dio dio = Dio();
  String domain = ServerDomain.domain;

  TextEditingController contextController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  FocusNode contentFocusNode = FocusNode();

  // 측정 상황 리스트
  List<DropdownMenuEntry<String>> categoryList = [];
  // 선택한 측정 상황 값
  String? selectContext;

  DropdownMenuEntry<String> makeMenuEntry({required String value, required String label}) {
    return DropdownMenuEntry(
      value : value,
      label : label,
      style : ButtonStyle(
          textStyle : WidgetStatePropertyAll(TextStyle(fontSize : 16, fontWeight : FontWeight.bold))
      ),
    );
  }

  // 게시물 정보 가져오기
  Future<void> findPost() async {
    try {
      final response = await dio.get("$domain/board/${widget.boardPostId}");
      if(response.statusCode == 200) {
        final data = response.data;
        setState(() {
          contextController.text = data["boardCategoryTitle"];
          titleController.text = data["boardPostTitle"];
          contentController.text = htmlToPlain(data["boardPostContent"]);
        });
      }
    } on DioException catch(e) {

    }
  }

  // 게시물 수정
  Future<void> updatePost() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if(token == null) { return; }
      final data = {
        "boardCategoryTitle" : contextController.text,
        "boardPostTitle" : titleController.text,
        "boardPostContent" : toHtmlWithBr(contentController.text),
      };
      final response = await dio.put("$domain/board/${widget.boardPostId}", data : data, options : Options(headers : {"Authorization" : token}));
      if(response.statusCode == 200) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "수정하기", content : "게시물을 정상적으로 수정했습니다.", isChange : false),
        );
        Navigator.pop(context, true);
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 400) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "수정하기", content : "게시물을 수정하지 못했습니다.", isChange : false),
        );
      }
    }
  }

  // 카테고리 불러오기
  Future<void> readCategory() async {
    categoryList.add(makeMenuEntry(value : "1", label : "공지"));
    categoryList.add(makeMenuEntry(value : "2", label : "자유"));
    categoryList.add(makeMenuEntry(value : "3", label : "혈당"));
    categoryList.add(makeMenuEntry(value : "4", label : "혈압"));
    categoryList.add(makeMenuEntry(value : "5", label : "운동"));
  }

  // HTML → TextField (\n)
  String htmlToPlain(String html) {
    String s = html;
    // <br>, <br/>, <br /> → \n  (대소문자 무시)
    s = s.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    // </p><p> → 빈 줄 하나  (문단 경계)
    s = s.replaceAll(RegExp(r'</p>\s*<p>', caseSensitive: false), '\n\n');
    // 남은 <p>, </p> 제거
    s = s.replaceAll(RegExp(r'</?p>', caseSensitive: false), '');
    // &nbsp; → 공백
    s = s.replaceAll('&nbsp;', ' ');
    return s;
  }

  String toHtmlWithBr(String plain) {
    // XSS 대비: 내용은 먼저 이스케이프
    final escaped = const HtmlEscape(HtmlEscapeMode.element).convert(plain);
    return escaped.replaceAll(RegExp(r'\r\n?|\n'), '<br/>');
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    contentFocusNode.unfocus();
    // readContext();
    readCategory();
    findPost();
    // contextController.text = widget.boardCategoryTitle;
    // titleController.text = widget.boardPostTitle;
    // contentController.text = widget.boardPostContent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        title : Text("게시물 작성"),
      ),
      body : SafeArea(
        child : SingleChildScrollView(
          child : Container(
            padding : const EdgeInsets.symmetric(horizontal : 32, vertical : 8),
            width : double.infinity,
            child : Column(
              crossAxisAlignment : CrossAxisAlignment.start,
              children : [
                // 카테고리
                Container(
                  padding : const EdgeInsets.only(bottom : 8),
                  child: Text("카테고리(분류)"),
                ),
                LayoutBuilder(
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
                        dropdownMenuEntries : categoryList.isEmpty ? [] : categoryList,
                      );
                    }
                ),
                SizedBox(height : 8),

                // 제목
                Container(
                  padding : const EdgeInsets.only(bottom : 8),
                  child: Text("제목"),
                ),
                TextField(
                  controller : titleController,
                  decoration : InputDecoration(
                    hintText : "제목을 입력해주세요",
                    enabledBorder : OutlineInputBorder(
                      borderRadius : BorderRadius.circular(8),
                      borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                    ),
                    focusedBorder : OutlineInputBorder(
                      borderRadius : BorderRadius.circular(8),
                      borderSide : BorderSide(color : AppColors.mainColor, width : 2),
                    ),
                  ),
                ),
                SizedBox(height : 8),

                // 내용
                Container(
                  padding : const EdgeInsets.only(bottom : 8),
                  child: Text("내용"),
                ),
                TextField(
                  controller : contentController,
                  maxLines : 10,
                  focusNode : contentFocusNode,
                  decoration : InputDecoration(
                    enabledBorder : OutlineInputBorder(
                      borderRadius : BorderRadius.circular(8),
                      borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                    ),
                    focusedBorder : OutlineInputBorder(
                      borderRadius : BorderRadius.circular(8),
                      borderSide : BorderSide(color : AppColors.mainColor, width : 2),
                    ),
                  ),
                ),
                SizedBox(height : 8),

                // 수정하기
                SizedBox(
                  width : double.infinity,
                  child : ElevatedButton(
                    onPressed : updatePost,
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
