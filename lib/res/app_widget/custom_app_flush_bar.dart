import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/app_color.dart';

class FlushbarHelper {
  FlushbarHelper._();

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
        color: AppColor.primaryColor,
      ),
      duration: duration ?? Duration(seconds: 3),
      leftBarIndicatorColor: AppColor.primaryColor,
      backgroundColor: AppColor.secondaryPrimaryColor,
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      flushbarPosition: position,
      animationDuration: Duration(milliseconds: 500),
    ).show(context);
  }

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
      backgroundColor: AppColor.secondaryPrimaryColor,
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      flushbarPosition: position,
      animationDuration: Duration(milliseconds: 500),
    ).show(context);
  }

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
        color: AppColor.lighterBlue,
      ),
      duration: duration ?? Duration(seconds: 3),
      leftBarIndicatorColor: AppColor.lighterBlue,
      backgroundColor: AppColor.secondaryPrimaryColor,
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      flushbarPosition: position,
      animationDuration: Duration(milliseconds: 500),
    ).show(context);
  }

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
      backgroundColor: AppColor.secondaryPrimaryColor,
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      flushbarPosition: position,
      animationDuration: Duration(milliseconds: 500),
    ).show(context);
  }

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
      leftBarIndicatorColor: indicatorColor ?? AppColor.primaryColor,
      backgroundColor: backgroundColor ?? AppColor.secondaryPrimaryColor,
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      flushbarPosition: position,
      animationDuration: Duration(milliseconds: 500),
      onTap: onTap != null ? (_) => onTap() : null,
    ).show(context);
  }

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
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
        ),
      ),
      duration: null,
      leftBarIndicatorColor: AppColor.primaryColor,
      backgroundColor: AppColor.secondaryPrimaryColor,
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
        color: AppColor.primaryColor,
      ),
      duration: duration ?? Duration(seconds: 5),
      leftBarIndicatorColor: AppColor.primaryColor,
      backgroundColor: AppColor.secondaryPrimaryColor,
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
            color: AppColor.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ).show(context);
  }
}