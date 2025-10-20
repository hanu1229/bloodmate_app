import 'package:bloodmate_app/style/app_color.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {

  final String title;
  final String content;
  final bool isChange;

  const CustomAlertDialog({
    super.key,
    required BuildContext context,
    required this.title,
    required this.content,
    required this.isChange
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor : Colors.white,
      shape : RoundedRectangleBorder(
        borderRadius : BorderRadius.circular(8.0),
      ),
      title : Text(title),
      content : Text(content, style : TextStyle(fontSize : 16)),
      actions : [
        ElevatedButton(
          style : ElevatedButton.styleFrom(
            backgroundColor : AppColors.mainColor,
            shape : RoundedRectangleBorder(
              borderRadius : BorderRadius.circular(8.0),
            ),
          ),
          onPressed : () {
            Navigator.pop(context);
            if(isChange) {
              Navigator.pop(context, true);
            }
          },
          child : Text("확인", style : TextStyle(color : Colors.white)),
        ),
      ],
    );
  }
}
