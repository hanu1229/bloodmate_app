import 'package:bloodmate_app/modals/CustomAlertDialog.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateCommentPage extends StatefulWidget {
  final int commentId;
  final String comment;
  const UpdateCommentPage({
    super.key,
    required this.commentId,
    required this.comment,
  });

  @override
  State<UpdateCommentPage> createState() => _UpdateCommentPageState();
}

class _UpdateCommentPageState extends State<UpdateCommentPage> {
  
  Dio dio = Dio();
  String domain = ServerDomain.domain;
  
  TextEditingController commentController = TextEditingController();
  FocusNode focusNode = FocusNode();

  // 댓글 수정하기
  Future<void> updateComment() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final data = {"boardCommentContent" : commentController.text};
      final response = await dio.put("$domain/board/comment/${widget.commentId}", data : data, options : Options(headers : {"Authorization" : token}));
      if(response.statusCode == 200) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "댓글 수정", content : "댓글 수정에 성공했습니다.", isChange : false),
        );
        Navigator.pop(context, true);
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 400) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "댓글 수정", content : "댓글 수정에 실패했습니다.", isChange : false),
        );
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    commentController.text = widget.comment;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar : AppBar(
        title : Text("댓글 수정하기"),
      ),
      body : SafeArea(
        child : Container(
          padding : const EdgeInsets.symmetric(horizontal : 16, vertical : 8),
          width : double.infinity,
          child : Column(
            children : [
              TextField(
                controller : commentController,
                maxLines : 10,
                focusNode : focusNode,
                decoration : InputDecoration(
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
              SizedBox(height : 8),
              Row(
                mainAxisAlignment : MainAxisAlignment.end,
                children : [
                  ElevatedButton(
                    onPressed : updateComment,
                    child : Text("수정하기"),
                  ),
                  SizedBox(width : 16),
                  ElevatedButton(
                    style : ElevatedButton.styleFrom(
                      backgroundColor : Colors.grey,
                    ),
                    onPressed : () {
                      Navigator.pop(context, false);
                    },
                    child : Text("취소하기"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}