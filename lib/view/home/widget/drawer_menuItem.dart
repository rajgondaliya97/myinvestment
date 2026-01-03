import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../utils/app_color.dart';

class DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const DrawerMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
          colors: [
            AppColor.primaryColor.withOpacity(0.5),
            AppColor.secondaryPrimaryColor.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isSelected ? null : AppColor.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: isSelected
            ? Border.all(
          color: AppColor.primaryColor.withOpacity(0.4),
          width: 1.w,
        )
            : null,
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: isSelected
              ? BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor.primaryColor,
                AppColor.secondaryPrimaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(8.r),
          )
              : null,
          child: Icon(
            icon,
            color: isSelected ? AppColor.lighterGreen : AppColor.grey500,
            size: 24.sp,
          ),
        ),
        title: ShaderMask(
          shaderCallback: isSelected
              ? (bounds) => LinearGradient(
            colors: [AppColor.lighterGreen, AppColor.primaryColor],
          ).createShader(bounds)
              : (bounds) => LinearGradient(
            colors: [AppColor.white, AppColor.white],
          ).createShader(bounds),
          child: AppText.medium(
            title,
            color: AppColor.white,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}