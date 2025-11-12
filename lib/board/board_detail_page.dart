import 'package:bloodmate_app/board/delete_board_page.dart';
import 'package:bloodmate_app/board/update_board_page.dart';
import 'package:bloodmate_app/comment/comment_page.dart';
import 'package:bloodmate_app/modals/CustomAlertDialog.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BoardDetailPage extends StatefulWidget {
  final int boardPostId;
  const BoardDetailPage({
    super.key,
    required this.boardPostId,
  });

  @override
  State<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {

  Dio dio = Dio();
  String domain = ServerDomain.domain;
  Map<String, dynamic> info = {};
  String date = "";
  String time = "";
  int countComment = 0;

  WebViewController controller = WebViewController();
  TextEditingController commentController = TextEditingController();

  /// 게시물 상세정보 불러오기
  Future<void> findDetail() async {
    try {
      final response = await dio.get("$domain/board/${widget.boardPostId}");
      if(response.statusCode == 200) {
        print(response.data);
        setState(() {
          info.addAll(response.data);
          date = info["createdAt"].split("T")[0];
          time = info["createdAt"].split("T")[1];
          controller.setJavaScriptMode(JavaScriptMode.unrestricted);
          controller.loadHtmlString(info["boardPostContent"]);
          countComment = info["commentDtoList"].length;
        });
      }
    } on DioException catch(e) {

    }
  }

  /// 게시물 작성자 확인
  Future<bool> checkWriter({required int boardPostId}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if(token == null) { return false; }
      final response = await dio.get("$domain/board/check-writer/$boardPostId", options : Options(headers : {"Authorization" : token}));
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
    findDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        title : info.isNotEmpty ? Text(info["boardPostTitle"]) : null,
        shape : Border(bottom : BorderSide(width : 1)),
      ),
      body : info.isNotEmpty ?
              SafeArea(
                child : Container(
                  padding : const EdgeInsets.symmetric(horizontal : 16, vertical : 8),
                  width : double.infinity,
                  child : Column(
                    children : [
                      Card(
                        shape : RoundedRectangleBorder(
                          borderRadius : BorderRadius.circular(8.0),
                          side : BorderSide(color : AppColors.mainColor),
                        ),
                        color : Color(0xFFFBFCFE),
                        child : Container(
                          padding : const EdgeInsets.symmetric(horizontal : 16),
                          child : Row(
                            mainAxisAlignment : MainAxisAlignment.spaceBetween,
                            children : [
                              Text(info["userNickname"], style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                              Row(
                                children : [
                                  Text(date, style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                                  SizedBox(width : 8),
                                  IconButton(
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
                                                        bool checkResult = await checkWriter(boardPostId : info["boardPostId"]);
                                                        if(checkResult == true) {
                                                          final result = await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder : (context) => UpdateBoardPage(
                                                                boardPostId : info["boardPostId"],
                                                                boardCategoryTitle : info["boardCategoryTitle"],
                                                                boardPostTitle : info["boardPostTitle"],
                                                                boardPostContent : info["boardPostContent"],
                                                              ),
                                                            ),
                                                          );
                                                          if(result != null && result == true) {
                                                            Navigator.pop(context);
                                                            Navigator.pop(context, true);
                                                          }
                                                        } else {
                                                          await showDialog(
                                                            context : context,
                                                            builder : (context) => CustomAlertDialog(context : context, title : "수정하기", content : "본인이 작성한 게시물이 아닙니다.", isChange : false),
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
                                                        bool checkResult = await checkWriter(boardPostId : info["boardPostId"]);
                                                        if(checkResult == true) {
                                                          final result = await showDialog(
                                                              context : context,
                                                              barrierDismissible : false,
                                                              builder : (context) => DeleteBoardPage(boardPostId : info["boardPostId"])
                                                          );
                                                          if(result != null && result == info["boardPostId"]) {
                                                            Navigator.pop(context);
                                                            Navigator.pop(context, true);
                                                          }
                                                        } else {
                                                          await showDialog(
                                                            context : context,
                                                            builder : (context) => CustomAlertDialog(context : context, title : "삭제하기", content : "본인이 작성한 게시물이 아닙니다.", isChange : false),
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
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child : Card(
                          shape : RoundedRectangleBorder(
                            borderRadius : BorderRadius.circular(8.0),
                            side : BorderSide(color : AppColors.mainColor),
                          ),
                          color : Color(0xFFFBFCFE),
                          child : Container(
                            padding : const EdgeInsets.symmetric(horizontal : 8.0, vertical : 8.0),
                            child : WebViewWidget(
                              controller : controller,
                            ),
                          ),
                        ),
                      ),
                      Card(
                        shape : RoundedRectangleBorder(
                          borderRadius : BorderRadius.circular(8.0),
                          side : BorderSide(color : AppColors.mainColor),
                        ),
                        color : Color(0xFFFBFCFE),
                        child : Container(
                          decoration : BoxDecoration(
                            color : AppColors.mainColor,
                            borderRadius : BorderRadius.circular(8.0),
                          ),
                          width : double.infinity,
                          child : TextButton(
                            onPressed : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder : (context) => CommentPage(
                                    commentDtoList : info["commentDtoList"],
                                    boardPostId : info["boardPostId"],
                                  ),
                                ),
                              );
                            },
                            child : Text("댓글보기 +$countComment", style : TextStyle(color : Colors.white, fontSize : 16, fontWeight : FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ) : null,
    );
  }
}
