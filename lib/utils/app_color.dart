import 'dart:ui';
import 'package:flutter/material.dart';

class AppColor {
  AppColor._(); // Private constructor to prevent instantiation

  // Brand Colors
  static const Color primaryColor = Color(0xFF116713);
  static const Color secondaryPrimaryColor = Color(0xFF031c40);
  static const Color lighterGreen = Color(0xFF1A8F1F);
  static const Color lighterBlue = Color(0xFF052A5F);

  // Semantic Colors (Feedback)
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFB300);
  static const Color orange = Color(0xFFFF9800);
  static const Color info = Color(0xFF1E88E5);

  // Neutral Colors (Greys & Backgrounds)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFF020E21); // Dark background
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color transparent = Colors.transparent;

  // Gradients (Moving logic from CustomAppBar and AppButton)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [primaryColor, secondaryPrimaryColor],
  );

  static LinearGradient glassGradient = LinearGradient(
    colors: [
      secondaryPrimaryColor.withOpacity(0.9),
      lighterBlue.withOpacity(0.9),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient screenGradientBgColor = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColor.secondaryPrimaryColor,
      AppColor.primaryColor.withOpacity(0.3),
      AppColor.secondaryPrimaryColor,
    ],
  );

 static LinearGradient cardGradientBgColor =  LinearGradient(
   colors: [
     AppColor.secondaryPrimaryColor.withOpacity(0.8),
     AppColor.primaryColor.withOpacity(0.2),
   ],
 );

}