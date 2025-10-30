import 'package:bloodmate_app/board/board_detail_page.dart';
import 'package:bloodmate_app/board/create_board_page.dart';
import 'package:bloodmate_app/server_domain.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:bloodmate_app/user/login_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardPage extends StatefulWidget {

  /// <b>게시판 페이지</b>
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();

}

class _BoardPageState extends State<BoardPage> {

  Dio dio = Dio();
  String domain = ServerDomain.domain;

  // 공지 게시물 리스트
  List<dynamic> noticeList = [];
  // 공지 외 게시물 리스트
  List<dynamic> otherList = [];
  // 공지 + 그외 게시물 리스트
  List<dynamic> postList = [];
  // 선택한 카테고리
  String selectCategory = "전체";

  // 공지 일부 게시물 가져오기 (서버에서 최근 3개만 보냄)
  Future<void> findNotices() async {
    try {
      final response = await dio.get("$domain/board/notice");
      if(response.statusCode == 200) {
        print("notices");
        print(response.data);
        setState(() { noticeList.addAll(response.data); });
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 400) {
        print("에러");
      }
    }
  }

  // 공지 제외 게시물 가져오기
  Future<void> findData({required String boardCategoryTitle}) async {
    try {
      String url;
      if(boardCategoryTitle == "전체") {
        url = "$domain/board";
      } else {
        url = "$domain/board/category/$boardCategoryTitle";
      }
      final response = await dio.get(url);
      if(response.statusCode == 200) {
        print("other");
        print(response.data);
        setState(() { otherList.addAll(response.data); });
      }
    } on DioException catch(e) {
      if(e.response?.statusCode == 400) {
        print("에러");
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firstMethod();
  }

  // 최초 1회 실행
  Future<void> firstMethod() async {
    await findNotices();
    await findData(boardCategoryTitle : "전체");
    postList.addAll(noticeList);
    postList.addAll(otherList);
    print(postList);
  }

  //
  Future<void> refresh() async {
    setState(() {
      noticeList.clear();
      otherList.clear();
      postList.clear();
    });
    await findNotices();
    await findData(boardCategoryTitle : selectCategory);
    setState(() {
      if(selectCategory != "공지") {
        postList.addAll(noticeList);
      }
      postList.addAll(otherList);
    });
  }

  Widget customListTile({required String title, required String categoryTitle, required Icon icon}) {
    return ListTile(
      leading : icon,
      title : Text(title),
      onTap : () async {
        setState(() {
          noticeList.clear();
          otherList.clear();
          postList.clear();
        });
        await findNotices();
        await findData(boardCategoryTitle : categoryTitle);
        setState(() {
          selectCategory = categoryTitle;
          if(selectCategory != "공지") {
            postList.addAll(noticeList);
          }
          postList.addAll(otherList);
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        title : Text("게시판"),
        leading : BackButton(),
        actions : [
          Builder(
            builder : (context) => Padding(
              padding : const EdgeInsets.symmetric(horizontal : 8.0),
              child : IconButton(
                onPressed : () { Scaffold.of(context).openEndDrawer(); },
                tooltip : "카테고리",
                icon : Icon(Icons.menu),
              ),
            ),
          ),
        ],
      ),
      body : SafeArea(
        child : Container(
          width : double.infinity,
          child : Column(
            crossAxisAlignment : CrossAxisAlignment.start,
            children : [
              Container(
                padding : const EdgeInsets.symmetric(horizontal : 16, vertical : 8),
                width : double.infinity,
                decoration : BoxDecoration(
                  border : Border(top : BorderSide(color : Colors.black26, width : 1), bottom : BorderSide(color : Colors.black26, width : 1)),
                ),
                child: Row(
                  mainAxisAlignment : MainAxisAlignment.spaceBetween,
                  children : [
                    Text(selectCategory, style : TextStyle(fontSize : 20, fontWeight : FontWeight.bold)),
                    SizedBox(
                      width : 40,
                      height : 40,
                      child : IconButton(
                        onPressed : () async {
                          setState(() {
                            noticeList.clear();
                            otherList.clear();
                            postList.clear();
                          });
                          await findNotices();
                          await findData(boardCategoryTitle : selectCategory);
                          setState(() {
                            if(selectCategory != "공지") {
                              postList.addAll(noticeList);
                            }
                            postList.addAll(otherList);
                          });
                        },
                        icon : Icon(Icons.refresh, size : 24),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child : ListView.builder(
                  itemCount : postList.length,
                  itemBuilder : (context, index) {
                    final post = postList[index];
                    String dateTime = post["createdAt"];
                    String date = dateTime.split("T")[0];
                    String time = dateTime.split("T")[1];
                    return Container(
                      decoration : BoxDecoration(
                        border : Border(bottom : BorderSide(color : Colors.black26, width : 1)),
                      ),
                      child : ListTile(
                        leading : Text(
                          post["boardCategoryTitle"],
                          style : TextStyle(
                            color : post["boardCategoryTitle"] == "공지" ? Colors.red : Colors.black,
                            fontSize : 16,
                            fontWeight : FontWeight.bold,
                          ),
                        ),
                        title : Text(post["boardPostTitle"]),
                        subtitle : Row(
                          mainAxisAlignment : MainAxisAlignment.spaceBetween,
                          children : [
                            Text("${post["userNickname"]}"),
                            Text(date),
                          ],
                        ),
                        trailing : Text("${post["boardPostView"]}", style : TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
                        onTap : () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder : (context) => BoardDetailPage(
                                boardPostId : post["boardPostId"],
                              ),
                            ),
                          );
                          if(result != null && result == true) {
                            setState(() {
                              noticeList.clear();
                              otherList.clear();
                              postList.clear();
                            });
                            await findNotices();
                            await findData(boardCategoryTitle : selectCategory);
                            setState(() {
                              if(selectCategory != "공지") {
                                postList.addAll(noticeList);
                              }
                              postList.addAll(otherList);
                            });
                          }
                        },
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
      endDrawer : NavigationDrawer(
        backgroundColor : Colors.white,
        children : [
          // 로고
          Row(
            children : [
              Container(
                margin : const EdgeInsets.symmetric(horizontal : 8, vertical : 8),
                width : 48,
                height : 48,
                child : Image.asset("assets/images/bloodmate_logo-default.png"),
              ),
              Padding(
                padding : const EdgeInsets.only(left : 16.0),
                child : Text("블러드 메이트", style : TextStyle(color : AppColors.mainTextColor, fontSize : 32, fontWeight : FontWeight.bold)),
              ),
            ],
          ),
          Divider(height : 0, color : AppColors.mainColor),

          // 게시물 작성하기
          Container(
            padding : const EdgeInsets.symmetric(horizontal : 8, vertical : 8),
            child : ElevatedButton(
              onPressed : () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                final token = prefs.getString("token");
                if(token != null) {
                  final result = await Navigator.push(context, MaterialPageRoute(builder : (context) => CreateBoardPage()));
                  if(result != null && result == true) {
                    Navigator.pop(context);
                    refresh();
                  }
                } else {
                  Navigator.push(context, MaterialPageRoute(builder : (context) => LoginPage()));
                }

              },
              child : Text("게시물 작성"),
            ),
          ),
          Divider(height : 0, color : AppColors.mainColor),

          // 전체
          customListTile(title : "전체", categoryTitle : "전체", icon : Icon(Icons.article)),

          // 공지
          customListTile(title : "공지", categoryTitle : "공지", icon : Icon(Icons.campaign)),

          // 자유
          customListTile(title : "자유", categoryTitle : "자유", icon : Icon(Icons.chat_bubble)),

          // 혈당
          customListTile(title : "혈당", categoryTitle : "혈당", icon : Icon(Icons.water_drop)),

          // 혈압
          customListTile(title : "혈압", categoryTitle : "혈압", icon : Icon(Icons.monitor_heart)),

          // 운동
          customListTile(title : "운동", categoryTitle : "운동", icon : Icon(Icons.fitness_center)),
        ],
      ),
    );
  }

}