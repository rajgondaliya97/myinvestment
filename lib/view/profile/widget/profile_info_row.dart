import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../utils/app_color.dart';

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool isCopyable;

  const ProfileInfoRow({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.isCopyable = false,
  }) : super(key: key);

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppColor.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text('Copied to clipboard!'),
          ],
        ),
        backgroundColor: AppColor.primaryColor,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon (if provided)
        if (icon != null) ...[
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primaryColor.withOpacity(0.2),
                  AppColor.lighterGreen.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppColor.primaryColor.withOpacity(0.3),
                width: 1.w,
              ),
            ),
            child: Icon(
              icon,
              color: AppColor.lighterGreen,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
        ],

        // Label and Value
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.small(
                label,
                color: AppColor.grey500,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Expanded(
                    child: valueColor != null
                        ? ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          valueColor!,
                          valueColor!.withOpacity(0.8),
                        ],
                      ).createShader(bounds),
                      child: AppText.medium(
                        value,
                        color: AppColor.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                        : AppText.medium(
                      value,
                      color: AppColor.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Copy button (if copyable)
                  if (isCopyable) ...[
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => _copyToClipboard(context, value),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColor.primaryColor.withOpacity(0.3),
                              AppColor.lighterGreen.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColor.primaryColor.withOpacity(0.4),
                            width: 1.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.primaryColor.withOpacity(0.2),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.copy,
                          size: 16.sp,
                          color: AppColor.lighterGreen,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}