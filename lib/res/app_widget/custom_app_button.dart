import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/res/app_widget/custom_app_text.dart';

import '../../utils/app_color.dart';

class AppButton extends StatelessWidget {
  AppButton({
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
    this.buttonType = ButtonType.primary,
  });

  AppButton.primary({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height = 45,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w700,
    this.borderRadius = 13,
    this.isLoading = false,
    this.enabled = true,
    this.elevation = 0,
    this.borderColor,
    this.borderWidth = 2,
    this.icon,
    this.iconSize,
  }) : buttonType = ButtonType.primary;

  AppButton.secondary({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height = 45,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w700,
    this.borderRadius = 13,
    this.isLoading = false,
    this.enabled = true,
    this.elevation = 0,
    this.borderColor,
    this.borderWidth = 2,
    this.icon,
    this.iconSize,
  }) : buttonType = ButtonType.secondary;

  AppButton.outlined({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height = 45,
    this.backgroundColor = Colors.transparent,
    this.textColor = Colors.white,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w600,
    this.borderRadius = 13,
    this.isLoading = false,
    this.enabled = true,
    this.elevation = 0,
    this.borderColor,
    this.borderWidth = 2,
    this.icon,
    this.iconSize,
  }) : buttonType = ButtonType.outlined;

  AppButton.small({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height = 45,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w600,
    this.borderRadius = 13,
    this.isLoading = false,
    this.enabled = true,
    this.elevation = 0,
    this.borderColor,
    this.borderWidth = 2,
    this.icon,
    this.iconSize = 18,
  }) : buttonType = ButtonType.small;

  AppButton.text({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height = 45,
    this.backgroundColor = Colors.transparent,
    this.textColor = Colors.white,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w600,
    this.borderRadius = 13,
    this.isLoading = false,
    this.enabled = true,
    this.elevation = 0,
    this.borderColor,
    this.borderWidth,
    this.icon,
    this.iconSize = 18,
  }) : buttonType = ButtonType.text;

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
  final ButtonType buttonType;

  // Static gradient definitions
  final LinearGradient _primaryGradient = LinearGradient(
    colors: [
      AppColor.secondaryPrimaryColor.withValues(alpha: 0.0),
      AppColor.primaryColor.withValues(alpha: 0.1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient _borderGradient = LinearGradient(
    colors: [
      AppColor.primaryColor,
      AppColor.secondaryPrimaryColor,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !enabled || isLoading;
    final gradient = _primaryGradient;
    final borderGradient = _borderGradient;

    return SizedBox(
      width: width?.w ?? double.infinity,
      height: height?.h ?? 60.h,
      child: Container(
        decoration: BoxDecoration(
          // Gradient border effect
          gradient: LinearGradient(
            colors: borderGradient.colors
                .map((c) => c.withOpacity(0.4))
                .toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius?.r ?? 16.r),
          boxShadow: !isDisabled && elevation != null && elevation! > 0
              ? [
                  BoxShadow(
                    color: AppColor.primaryColor.withOpacity(0.3),
                    blurRadius: elevation! * 4,
                    spreadRadius: 1,
                    offset: Offset(0, elevation! * 2),
                  ),
                ]
              : null,
        ),
        child: Container(
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient.colors.map((c) => c.withOpacity(0.7)).toList(),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(
              (borderRadius?.r ?? 16.r) - (borderWidth?.w ?? 2.w),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : onPressed,
              borderRadius: BorderRadius.circular(
                (borderRadius?.r ?? 16.r) - (borderWidth?.w ?? 2.w),
              ),
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        height: 22.h,
                        width: 22.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5.w,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              size: iconSize?.sp ?? 18.sp,
                              color: isDisabled
                                  ? textColor?.withOpacity(0.5)
                                  : textColor,
                            ),
                            SizedBox(width: 12.w),
                          ],
                          AppText.small(
                            text,
                            fontSize: fontSize?.sp ?? 8.sp,
                            fontWeight: fontWeight ?? FontWeight.w600,
                            color: isDisabled
                                ? textColor?.withOpacity(0.5)
                                : textColor,
                            letterSpacing: 0.5,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Enum for button types
enum ButtonType { primary, secondary, outlined, small, text }
