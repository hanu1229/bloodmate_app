import 'package:bloodmate_app/modals/CustomAlertDialog.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteCommentPage extends StatefulWidget {
  final int commentId;
  const DeleteCommentPage({
    super.key,
    required this.commentId,
  });

  @override
  State<DeleteCommentPage> createState() => _DeleteCommentPageState();
}

class _DeleteCommentPageState extends State<DeleteCommentPage> {

  Dio dio = Dio();
  String domain = ServerDomain.domain;

  // 댓글 삭제하기
  Future<void> deleteComment() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if(token == null) { return; }
      final response = await dio.delete("$domain/board/comment/${widget.commentId}", options : Options(headers : {"Authorization" : token}));
      if(response.statusCode == 200) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "삭제하기", content : "댓글을 정상적으로 삭제했습니다.", isChange : false),
        );
        Navigator.pop(context, widget.commentId);
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 400) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "삭제하기", content : "댓글을 삭제하지 못했습니다.", isChange : false),
        );
        Navigator.pop(context);
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
      title : Text("댓글 삭제하기"),
      content : Column(
        crossAxisAlignment : CrossAxisAlignment.start,
        mainAxisSize : MainAxisSize.min,
        children : [
          Text("※ 정말 삭제하시겠습니까?", style : TextStyle(color : Colors.red, fontSize : 24, fontWeight : FontWeight.bold)),
          Text("※ 댓글이 영구 삭제되어 복구 할 수 없습니다.", style : TextStyle(color : Colors.red, fontSize : 24, fontWeight : FontWeight.bold)),
        ],
      ),
      actions : [
        ElevatedButton(
          style : ElevatedButton.styleFrom(
            backgroundColor : Colors.red,
            shape : RoundedRectangleBorder(borderRadius : BorderRadius.circular(8.0)),
          ),
          onPressed : deleteComment,
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
