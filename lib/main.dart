import 'package:bloodmate_app/main_layout.dart';
import 'package:bloodmate_app/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const BloodMate());
}

class BloodMate extends StatelessWidget {
  const BloodMate({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner : false,
      localizationsDelegates : const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [ Locale('ko'), Locale('en') ],
      locale: const Locale('ko'),
      theme : ThemeData(
        useMaterial3 : true,
        // body 스크롤 시 AppBar 색상 변경 되는 현상 방지
        appBarTheme : AppBarTheme(
          scrolledUnderElevation : 0,
          surfaceTintColor : Colors.transparent,
          elevation : 0,
        ),
        datePickerTheme : DatePickerThemeData(
          backgroundColor : Colors.white,
          dayBackgroundColor : WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.mainColor;
            }
            return null;
          }),
          todayBackgroundColor : WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.mainColor;
            }
            return null;
          }),
        ),
        timePickerTheme : TimePickerThemeData(
          backgroundColor : Colors.white,
        ),
        elevatedButtonTheme : ElevatedButtonThemeData(
          style : ButtonStyle(
            shape : WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius : BorderRadius.circular(8.0))),
            backgroundColor : WidgetStatePropertyAll(AppColors.mainColor),
            textStyle : WidgetStatePropertyAll(TextStyle(fontSize : 16, fontWeight : FontWeight.bold)),
            foregroundColor : WidgetStatePropertyAll(Colors.white),
          ),
        ),
      ),
      title : "블러드메이트",
      home : MainLayout()
    );
  }

}