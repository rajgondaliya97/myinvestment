import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Custom Flushbar Helper for showing notifications across the app
class FlushbarHelper {
  // Private constructor to prevent instantiation
  FlushbarHelper._();

  /// Show success message with green theme
  static void showSuccess({
    required BuildContext context,
    required String message,
    String? title,
    Duration? duration,
    FlushbarPosition position = FlushbarPosition.TOP,
  }) {
    Flushbar(
      title: title,
      message: message,
      icon: Icon(
        Icons.check_circle,
        size: 28.sp,
        color: Color(0xFF00FF00),
      ),
      duration: duration ?? Duration(seconds: 3),
      leftBarIndicatorColor: Color(0xFF00FF00),
      backgroundColor: Colors.grey[900]!,
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      flushbarPosition: position,
      animationDuration: Duration(milliseconds: 500),
      boxShadows: [
        BoxShadow(
          color: Color(0xFF00FF00).withOpacity(0.2),
          offset: Offset(0, 2),
          blurRadius: 8,
        ),
      ],
    ).show(context);
  }

  /// Show error message with red theme
  static void showError({
    required BuildContext context,
    required String message,
    String? title,
    Duration? duration,
    FlushbarPosition position = FlushbarPosition.TOP,
  }) {
    Flushbar(
      title: title,
      message: message,
      icon: Icon(
        Icons.error_outline,
        size: 28.sp,
        color: Colors.red,
      ),
      duration: duration ?? Duration(seconds: 3),
      leftBarIndicatorColor: Colors.red,
      backgroundColor: Colors.grey[900]!,
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      flushbarPosition: position,
      animationDuration: Duration(milliseconds: 500),
      boxShadows: [
        BoxShadow(
          color: Colors.red.withOpacity(0.2),
          offset: Offset(0, 2),
          blurRadius: 8,
        ),
      ],
    ).show(context);
  }

  /// Show info message with blue theme
  static void showInfo({
    required BuildContext context,
    required String message,
    String? title,
    Duration? duration,
    FlushbarPosition position = FlushbarPosition.TOP,
  }) {
    Flushbar(
      title: title,
      message: message,
      icon: Icon(
        Icons.info_outline,
        size: 28.sp,
        color: Colors.blue,
      ),
      duration: duration ?? Duration(seconds: 3),
      leftBarIndicatorColor: Colors.blue,
      backgroundColor: Colors.grey[900]!,
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      flushbarPosition: position,
      animationDuration: Duration(milliseconds: 500),
      boxShadows: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.2),
          offset: Offset(0, 2),
          blurRadius: 8,
        ),
      ],
    ).show(context);
  }

  /// Show warning message with orange theme
  static void showWarning({
    required BuildContext context,
    required String message,
    String? title,
    Duration? duration,
    FlushbarPosition position = FlushbarPosition.TOP,
  }) {
    Flushbar(
      title: title,
      message: message,
      icon: Icon(
        Icons.warning_amber_outlined,
        size: 28.sp,
        color: Colors.orange,
      ),
      duration: duration ?? Duration(seconds: 3),
      leftBarIndicatorColor: Colors.orange,
      backgroundColor: Colors.grey[900]!,
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      flushbarPosition: position,
      animationDuration: Duration(milliseconds: 500),
      boxShadows: [
        BoxShadow(
          color: Colors.orange.withOpacity(0.2),
          offset: Offset(0, 2),
          blurRadius: 8,
        ),
      ],
    ).show(context);
  }

  /// Show custom message with custom color and icon
  static void showCustom({
    required BuildContext context,
    required String message,
    String? title,
    IconData? icon,
    Color? iconColor,
    Color? indicatorColor,
    Color? backgroundColor,
    Duration? duration,
    FlushbarPosition position = FlushbarPosition.TOP,
    VoidCallback? onTap,
  }) {
    Flushbar(
      title: title,
      message: message,
      icon: icon != null
          ? Icon(
        icon,
        size: 28.sp,
        color: iconColor ?? Colors.white,
      )
          : null,
      duration: duration ?? Duration(seconds: 3),
      leftBarIndicatorColor: indicatorColor ?? Color(0xFF00FF00),
      backgroundColor: backgroundColor ?? Colors.grey[900]!,
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      flushbarPosition: position,
      animationDuration: Duration(milliseconds: 500),
      onTap: onTap != null ? (_) => onTap() : null,
      boxShadows: [
        BoxShadow(
          color: (indicatorColor ?? Color(0xFF00FF00)).withOpacity(0.2),
          offset: Offset(0, 2),
          blurRadius: 8,
        ),
      ],
    ).show(context);
  }

  /// Show loading message (longer duration, no auto-dismiss)
  static Flushbar showLoading({
    required BuildContext context,
    String message = 'Loading...',
    String? title,
  }) {
    final flushbar = Flushbar(
      title: title,
      message: message,
      icon: SizedBox(
        width: 28.sp,
        height: 28.sp,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF00)),
        ),
      ),
      duration: null, // No auto-dismiss
      leftBarIndicatorColor: Color(0xFF00FF00),
      backgroundColor: Colors.grey[900]!,
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      flushbarPosition: FlushbarPosition.TOP,
      showProgressIndicator: false,
      isDismissible: false,
    );

    flushbar.show(context);
    return flushbar;
  }

  /// Show message with action button
  static void showWithAction({
    required BuildContext context,
    required String message,
    required String actionText,
    required VoidCallback onActionPressed,
    String? title,
    Duration? duration,
    FlushbarPosition position = FlushbarPosition.BOTTOM,
  }) {
    Flushbar(
      title: title,
      message: message,
      icon: Icon(
        Icons.info_outline,
        size: 28.sp,
        color: Color(0xFF00FF00),
      ),
      duration: duration ?? Duration(seconds: 5),
      leftBarIndicatorColor: Color(0xFF00FF00),
      backgroundColor: Colors.grey[900]!,
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      flushbarPosition: position,
      animationDuration: Duration(milliseconds: 500),
      mainButton: TextButton(
        onPressed: onActionPressed,
        child: Text(
          actionText.toUpperCase(),
          style: TextStyle(
            color: Color(0xFF00FF00),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ).show(context);
  }
}