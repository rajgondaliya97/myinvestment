import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.isLoading = false,
    this.enabled = true,
    this.elevation,
    this.borderColor,
    this.borderWidth,
    this.icon,
    this.iconSize,
  });

  const AppButton.primary({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height = 60,
    this.backgroundColor = const Color(0xFF00FF00),
    this.textColor = Colors.black,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w700,
    this.borderRadius = 16,
    this.isLoading = false,
    this.enabled = true,
    this.elevation = 0,
    this.borderColor,
    this.borderWidth,
    this.icon,
    this.iconSize,
  });

  const AppButton.secondary({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height = 60,
    this.backgroundColor = Colors.black,
    this.textColor = const Color(0xFF00FF00),
    this.fontSize = 18,
    this.fontWeight = FontWeight.w700,
    this.borderRadius = 16,
    this.isLoading = false,
    this.enabled = true,
    this.elevation = 0,
    this.borderColor = const Color(0xFF00FF00),
    this.borderWidth = 2,
    this.icon,
    this.iconSize,
  });

  const AppButton.outlined({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height = 60,
    this.backgroundColor = Colors.transparent,
    this.textColor = const Color(0xFF00FF00),
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.borderRadius = 16,
    this.isLoading = false,
    this.enabled = true,
    this.elevation = 0,
    this.borderColor = const Color(0xFF00FF00),
    this.borderWidth = 2,
    this.icon,
    this.iconSize,
  });

  const AppButton.small({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height = 45,
    this.backgroundColor = const Color(0xFF00FF00),
    this.textColor = Colors.black,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.borderRadius = 12,
    this.isLoading = false,
    this.enabled = true,
    this.elevation = 0,
    this.borderColor,
    this.borderWidth,
    this.icon,
    this.iconSize = 18,
  });

  const AppButton.text({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height = 40,
    this.backgroundColor = Colors.transparent,
    this.textColor = const Color(0xFF00FF00),
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.borderRadius = 8,
    this.isLoading = false,
    this.enabled = true,
    this.elevation = 0,
    this.borderColor,
    this.borderWidth,
    this.icon,
    this.iconSize = 16,
  });

  final VoidCallback? onPressed;
  final String text;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final bool isLoading;
  final bool enabled;
  final double? elevation;
  final Color? borderColor;
  final double? borderWidth;
  final IconData? icon;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !enabled || isLoading;

    return SizedBox(
      width: width?.w ?? double.infinity,
      height: height?.h ?? 60.h,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? backgroundColor?.withOpacity(0.5)
              : backgroundColor,
          foregroundColor: textColor,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius?.r ?? 16.r),
            side: borderColor != null
                ? BorderSide(
              color: isDisabled
                  ? borderColor!.withOpacity(0.5)
                  : borderColor!,
              width: borderWidth?.w ?? 2.w,
            )
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        child: isLoading
            ? SizedBox(
          height: 20.h,
          width: 20.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            valueColor: AlwaysStoppedAnimation<Color>(
              textColor ?? Colors.white,
            ),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize?.sp ?? 20.sp),
              SizedBox(width: 8.w),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize?.sp ?? 18.sp,
                fontWeight: fontWeight ?? FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}