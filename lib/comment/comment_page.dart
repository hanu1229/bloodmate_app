import 'package:bloodmate_app/comment/delete_comment_page.dart';
import 'package:bloodmate_app/comment/update_comment_page.dart';
import 'package:bloodmate_app/modals/CustomAlertDialog.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentPage extends StatefulWidget {
  final List<dynamic> commentDtoList;
  final int boardPostId;
  const CommentPage({
    super.key,
    required this.commentDtoList,
    required this.boardPostId,
  });

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {

  Dio dio = Dio();
  String domain = ServerDomain.domain;

  TextEditingController commentController = TextEditingController();
  FocusNode focusNode = FocusNode();

  /// 댓글 리스트
  List<dynamic> commentList = [];
  /// 댓글 정렬
  String selectSort = "DESC";
  
  /// 댓글 작성하기
  Future<void> writeComment() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final data = {
        "boardCommentContent" : commentController.text,
      };
      final response = await dio.post("$domain/board/comment/${widget.boardPostId}", data : data, options : Options(headers : {"Authorization" : token}));
      if(response.statusCode == 201) {
        await showDialog(
          context : context,
          builder : (context) => CustomAlertDialog(context : context, title : "댓글 작성", content : "댓글 작성에 성공했습니다.", isChange : false),
        );
        findComment(sort : selectSort);
        setState(() {
          commentController.clear();
          focusNode.unfocus();
        });
      }
    } on DioException catch(e) {

    }
  }

  /// 댓글 새로고침
  Future<void> findComment({required String sort}) async {
    try {
      final response = await dio.get("$domain/board/comment/${widget.boardPostId}", queryParameters : {"sort" : sort});
      if(response.statusCode == 200) {
        setState(() {
          commentList.clear();
          commentList.addAll(response.data);
        });
        print(response.data);
      }
    } on DioException catch(e) {

    }
  }
  
  /// 댓글 작성자 확인
  Future<bool> checkWriter({required int commentId}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if(token == null) { return false; }
      final response = await dio.get("$domain/board/comment/check-writer/$commentId", options : Options(headers : {"Authorization" : token}));
      if(response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch(e) {
      if(e.response?.statusCode == 400) {
        return false;
      }
      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    findComment(sort : selectSort);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar : AppBar(
        title : Text("댓글창"),
        actions : [
          Padding(
            padding: const EdgeInsets.only(right : 12),
            child: IconButton(
              onPressed : () {
                findComment(sort : selectSort);
              },
              icon : Icon(Icons.refresh)
            ),
          ),
        ],
      ),
      body : SafeArea(
        child : Container(
          padding : const EdgeInsets.symmetric(horizontal : 16, vertical : 8),
          width : double.infinity,
          child : Column(
            children : [
              Expanded(
                child: Card(
                  shape : RoundedRectangleBorder(
                    borderRadius : BorderRadius.circular(8.0),
                    side : BorderSide(color : Colors.grey),
                  ),
                  color : Color(0xFFFBFCFE),
                  child : Column(
                    children : [
                      Container(
                        decoration : BoxDecoration(border : Border(bottom : BorderSide(color : Colors.grey, width : 1))),
                        padding : const EdgeInsets.symmetric(horizontal : 16, vertical : 8),
                        width : double.infinity,
                        child : Row(
                          mainAxisAlignment : MainAxisAlignment.end,
                          children : [
                            GestureDetector(
                              onTap : () {
                                setState(() {
                                  selectSort = "ASC";
                                  findComment(sort : selectSort);
                                });
                              },
                              child : Text(
                                "등록순",
                                style : TextStyle(
                                  fontSize : 16,
                                  fontWeight : selectSort == "ASC" ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            Text("  |  "),
                            GestureDetector(
                              onTap : () {
                                setState(() {
                                  selectSort = "DESC";
                                  findComment(sort : selectSort);
                                });
                              },
                              child : Text(
                                "최신순",
                                style : TextStyle(
                                  fontSize : 16,
                                  fontWeight : selectSort == "DESC" ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child : ListView.builder(
                          itemCount : commentList.length,
                          itemBuilder : (context, index) {
                            final comment = commentList[index];
                            String dateTime = comment["createdAt"];
                            String date = dateTime.split("T")[0];
                            String hour = dateTime.split("T")[1].split(":")[0];
                            String minutes = dateTime.split("T")[1].split(":")[1];
                            return Padding(
                              padding : const EdgeInsets.only(top : 8, left : 16, right : 16),
                              child: Container(
                                padding : const EdgeInsets.symmetric(horizontal : 8, vertical : 8),
                                decoration : BoxDecoration(
                                  border : Border(bottom : BorderSide(color : Colors.grey, width : 1)),
                                ),
                                child : Column(
                                  crossAxisAlignment : CrossAxisAlignment.start,
                                  children : [
                                    Row(
                                      mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                      children : [
                                        Text(comment["userNickname"], style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                                        SizedBox(
                                          width : 24,
                                          height : 24,
                                          child : IconButton(
                                            onPressed : () async {
                                              await showModalBottomSheet(
                                                context : context,
                                                isScrollControlled : true,
                                                useSafeArea : true,
                                                backgroundColor : Colors.transparent,
                                                builder : (context) => Padding(
                                                  padding : const EdgeInsets.all(16),
                                                  child : SafeArea(
                                                    child : Container(
                                                      padding : const EdgeInsets.symmetric(horizontal : 32, vertical : 16),
                                                      height : 150,
                                                      width : double.infinity,
                                                      decoration : BoxDecoration(
                                                        color : Colors.white,
                                                        borderRadius : BorderRadius.circular(16.0),
                                                      ),
                                                      child : Column(
                                                        mainAxisAlignment : MainAxisAlignment.spaceAround,
                                                        children : [
                                                          // 수정 버튼
                                                          SizedBox(
                                                            width : double.infinity,
                                                            child : ElevatedButton(
                                                              onPressed : () async {
                                                                bool checkResult = await checkWriter(commentId : comment["boardCommentId"]);
                                                                if(checkResult == true) {
                                                                  final result = await Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder : (context) => UpdateCommentPage(
                                                                        commentId : comment["boardCommentId"],
                                                                        comment : comment["boardCommentContent"],
                                                                      ),
                                                                    ),
                                                                  );
                                                                  if(result != null && result == true) {
                                                                    findComment(sort : selectSort);
                                                                    Navigator.pop(context);
                                                                  }
                                                                } else {
                                                                  await showDialog(
                                                                    context : context,
                                                                    builder : (context) => CustomAlertDialog(context : context, title : "수정하기", content : "본인이 작성한 댓글이 아닙니다.", isChange : false),
                                                                  );
                                                                  Navigator.pop(context);
                                                                }
                                                              },
                                                              child : Text("수정하기"),
                                                            ),
                                                          ),
                                                          // 삭제 버튼
                                                          SizedBox(
                                                            width : double.infinity,
                                                            child : ElevatedButton(
                                                              style : ElevatedButton.styleFrom(
                                                                backgroundColor : Colors.red,
                                                                shape : RoundedRectangleBorder(borderRadius : BorderRadius.circular(8.0)),
                                                              ),
                                                              onPressed : () async {
                                                                bool checkResult = await checkWriter(commentId : comment["boardCommentId"]);
                                                                if(checkResult == true) {
                                                                  final result = await showDialog(
                                                                      context : context,
                                                                      barrierDismissible : false,
                                                                      builder : (context) => DeleteCommentPage(commentId : comment["boardCommentId"])
                                                                  );
                                                                  if(result != null && result == comment["boardCommentId"]) {
                                                                    setState(() { commentList.removeAt(index); });
                                                                    Navigator.pop(context);
                                                                  }
                                                                } else {
                                                                  await showDialog(
                                                                    context : context,
                                                                    builder : (context) => CustomAlertDialog(context : context, title : "삭제하기", content : "본인이 작성한 댓글이 아닙니다.", isChange : false),
                                                                  );
                                                                  Navigator.pop(context);
                                                                }
                                                              },
                                                              child : Text("삭제하기"),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            icon : Icon(Icons.more_horiz, size : 24),
                                            padding : EdgeInsets.zero,
                                            constraints : BoxConstraints(maxWidth : 24, maxHeight : 24),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height : 8),
                                    Text(comment["boardCommentContent"], style : TextStyle(fontSize : 16)),
                                    SizedBox(height : 8),
                                    Text("$date $hour:$minutes", style : TextStyle(fontSize : 16)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                shape : RoundedRectangleBorder(
                  borderRadius : BorderRadius.circular(8.0),
                  side : BorderSide(color : Colors.grey),
                ),
                color : Color(0xFFFBFCFE),
                child : Container(
                  padding : const EdgeInsets.symmetric(horizontal : 16, vertical : 16),
                  child : Column(
                    crossAxisAlignment : CrossAxisAlignment.start,
                    children : [
                      Text("댓글", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                      SizedBox(height : 8),
                      TextField(
                        controller : commentController,
                        maxLines : 3,
                        minLines : 1,
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
                            onPressed : writeComment,
                            child : Text("작성하기"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
