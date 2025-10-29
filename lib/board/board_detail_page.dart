import 'package:bloodmate_app/board/board_comment_page.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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

  WebViewController controller = WebViewController();
  TextEditingController commentController = TextEditingController();

  // 게시물 상세정보 불러오기
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
        });
      }
    } on DioException catch(e) {

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
                  padding : const EdgeInsets.symmetric(horizontal : 32, vertical : 8),
                  width : double.infinity,
                  child : Column(
                    children : [
                      Card(
                        shape : RoundedRectangleBorder(
                          borderRadius : BorderRadius.circular(8.0),
                          side : BorderSide(color : Colors.grey),
                        ),
                        color : Color(0xFFFBFCFE),
                        child : Container(
                          padding : const EdgeInsets.symmetric(horizontal : 16, vertical : 8),
                          child : Row(
                            mainAxisAlignment : MainAxisAlignment.spaceBetween,
                            children : [
                              Text(info["userNickname"], style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                              Text(date, style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child : Card(
                          shape : RoundedRectangleBorder(
                            borderRadius : BorderRadius.circular(8.0),
                            side : BorderSide(color : Colors.grey),
                          ),
                          color : Color(0xFFFBFCFE),
                          child : WebViewWidget(
                            controller : controller,
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
                          decoration : BoxDecoration(
                            color : AppColors.mainColor,
                            borderRadius : BorderRadius.circular(8.0),
                          ),
                          width : double.infinity,
                          child : TextButton(
                            onPressed : () {
                              Navigator.push(context, MaterialPageRoute(builder : (context) => BoardCommentPage()));
                            },
                            child : Text("댓글보기", style : TextStyle(color : Colors.white, fontSize : 16, fontWeight : FontWeight.bold)),
                          ),
                        ),
                      ),
                      // Card(
                      //   shape : RoundedRectangleBorder(
                      //     borderRadius : BorderRadius.circular(8.0),
                      //     side : BorderSide(color : Colors.grey),
                      //   ),
                      //   color : Color(0xFFFBFCFE),
                      //   child : Container(
                      //     padding : const EdgeInsets.symmetric(horizontal : 16, vertical : 16),
                      //     child : Column(
                      //       crossAxisAlignment : CrossAxisAlignment.start,
                      //       children : [
                      //         Text("댓글", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                      //         SizedBox(height : 8),
                      //         TextField(
                      //           controller : commentController,
                      //           maxLines : 5,
                      //           decoration : InputDecoration(
                      //             enabledBorder : OutlineInputBorder(
                      //               borderRadius : BorderRadius.circular(8.0),
                      //               borderSide : BorderSide(color : AppColors.mainColor, width : 1),
                      //             ),
                      //             focusedBorder : OutlineInputBorder(
                      //               borderRadius : BorderRadius.circular(8.0),
                      //               borderSide : BorderSide(color : AppColors.mainColor, width : 2),
                      //             ),
                      //           ),
                      //         ),
                      //         SizedBox(height : 8),
                      //         Row(
                      //           mainAxisAlignment : MainAxisAlignment.end,
                      //           children : [
                      //             ElevatedButton(
                      //               onPressed : () {},
                      //               child : Text("작성하기"),
                      //             ),
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ) : null,
    );
  }
}
