import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../color/app_colors.dart';

class AppTheme {
  static ThemeData lavendarTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.lavendarColorScheme),
    indicatorColor: AppColors.lavendarPrimaryColor,
    primaryColor: AppColors.lavendarPrimaryColor,
    secondaryHeaderColor: AppColors.lavendarSecondaryColor,
    useMaterial3: true,
    fontFamily: 'NunitoSans',
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.lavendarPrimaryColor,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
          color: AppColors.whiteColor, fontSize: 20, fontFamily: 'NunitoSans'),
      iconTheme: IconThemeData(color: AppColors.whiteColor),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xfff1f5f9),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
      ),
    ),
    scaffoldBackgroundColor: AppColors.whiteColor,
    dividerColor: Colors.grey.shade300,
  );
}
