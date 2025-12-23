import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../res/app_widget/custom_app_text.dart';

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
            Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text('Copied to clipboard!'),
          ],
        ),
        backgroundColor: Color(0xFF00FF00).withOpacity(0.8),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
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
          Icon(
            icon,
            color: Color(0xFF00FF00).withOpacity(0.6),
            size: 20.sp,
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
                color: Colors.grey[500],
                fontSize: 12,
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Expanded(
                    child: AppText.medium(
                      value,
                      color: valueColor ?? Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Copy button (if copyable)
                  if (isCopyable) ...[
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => _copyToClipboard(context, value),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          Icons.copy,
                          size: 16.sp,
                          color: Color(0xFF00FF00),
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