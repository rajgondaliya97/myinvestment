import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../res/app_widget/custom_app_text.dart';

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
        color: isSelected
            ? Color(0xFF00FF00).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: isSelected
            ? Border.all(
          color: Color(0xFF00FF00).withOpacity(0.3),
          width: 1.w,
        )
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Color(0xFF00FF00) : Colors.grey[400],
          size: 24.sp,
        ),
        title: AppText.medium(
          title,
          color: isSelected ? Color(0xFF00FF00) : Colors.white,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}