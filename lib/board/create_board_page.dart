import 'package:flutter/material.dart';

class CreateBoardPage extends StatefulWidget {
  const CreateBoardPage({super.key});

  @override
  State<CreateBoardPage> createState() => _CreateBoardPageState();
}

class _CreateBoardPageState extends State<CreateBoardPage> {
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
                Text("카테고리(분류)"),
                TextField(),
                Text("제목"),
                TextField(),
                Text("내용"),
                TextField(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
