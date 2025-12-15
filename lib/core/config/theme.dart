import 'package:aptcoder/core/config/const.dart';
import 'package:flutter/material.dart';

// 1. Color Definitions (Constants are correct)
const Color primaryColor = Color(0xff14796B); // 01
const Color accentColor = Color.fromARGB(255, 153, 253, 243); // 05 (Used as secondary/subtle accent)
const Color backgroundColor = Color(0xfff9f9f9); // 04
const Color headlineColor = Color(0xFF0C0A1C); // 03
const Color bodyTextColor = Color(0xFF261E58); // 02

// 2. Function to Return the Custom ThemeData Object
ThemeData get appThemeData {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    canvasColor: Colors.white,
    primaryColor: primaryColor,

    // 1. PRIMARY COLORS & ACCENTS
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surfaceBright: backgroundColor,

      surface: Colors.white, 
      onPrimary: Colors.white, 
      onSurface: bodyTextColor,
    ),

    // 2. TYPOGRAPHY
    textTheme: const TextTheme(
      // Headlines (H1, H2, Screen Titles)
      headlineLarge: TextStyle(
        color: headlineColor,
        fontSize: AppFontSize.largest,
        fontWeight: FontWeight.bold,
      ),
      // Body Text (Descriptions, Lesson Titles)
      bodyLarge: TextStyle(color: bodyTextColor, fontSize: AppFontSize.large),
      bodyMedium: TextStyle(color: bodyTextColor, fontSize: AppFontSize.medium),
      // Button Text (Text on the primary button)
      labelLarge: TextStyle(color: Colors.white),
    ),

    // 3. WIDGET STYLING
    appBarTheme: const AppBarTheme(
      color: primaryColor,
      foregroundColor: Colors.white, // Text/Icons on App Bar
      elevation: 0,
    ),
  );
}
