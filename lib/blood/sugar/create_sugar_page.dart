import 'package:flutter/material.dart';

class CreateSugarPage extends StatefulWidget {
  const CreateSugarPage({super.key});

  @override
  State<CreateSugarPage> createState() => _CreateSugarPageState();
}

class _CreateSugarPageState extends State<CreateSugarPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor : Colors.white,
      appBar : AppBar(
        title : Text("당화혈색소 작성하기"),
        backgroundColor : Colors.white,
      ),
      body : SafeArea(
        child : Container(
          padding : const EdgeInsets.symmetric(horizontal : 32.0, vertical : 16.0),
          width : double.infinity,
          child : Column(
            crossAxisAlignment : CrossAxisAlignment.start,
            children : [
              Text("측정일", style : TextStyle(fontSize : 16)),
              SizedBox(
                width : double.infinity,
                child : LayoutBuilder(
                    builder : (context, size) {
                      final width = size.maxWidth;
                      return DropdownMenu(
                        width : width,
                        hintText : "예시 : 20250101",
                        onSelected : (value) { setState(() { print(value); }); },
                        menuStyle : MenuStyle(
                          backgroundColor : WidgetStatePropertyAll(Colors.white),
                          alignment : AlignmentDirectional.bottomStart,
                        ),
                        dropdownMenuEntries : [
                          DropdownMenuEntry(value : "1", label : "식전"),
                          DropdownMenuEntry(value : "2", label : "식후"),
                          DropdownMenuEntry(value : "3", label : "취침 전"),
                        ],
                      );
                    }
                ),
              ),
              Text("측정 시간", style : TextStyle(fontSize : 16)),
              Text("당화혈색소 수치", style : TextStyle(fontSize : 16)),
              Text("다음 검사 예정일", style : TextStyle(fontSize : 16))
            ],
          ),
        ),
      ),
    );
  }
}
