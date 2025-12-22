import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? profileImageUrl;
  final VoidCallback? onProfileTap;
  final bool showLogo;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    this.title,
    this.profileImageUrl,
    this.onProfileTap,
    this.showLogo = true,
    this.actions,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(70.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 70.h,
      title: Row(
        children: [
          if (showLogo)
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Color(0xFF00FF00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.trending_up,
                color: Color(0xFF00FF00),
                size: 28.sp,
              ),
            ),
          if (showLogo && title != null) SizedBox(width: 12.w),
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      actions: [
        if (actions != null)
          ...actions!
        else
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFF00FF00),
                  width: 2.w,
                ),
                image: profileImageUrl != null
                    ? DecorationImage(
                  image: NetworkImage(profileImageUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
                color: Color(0xFF1A1A1A),
              ),
              child: profileImageUrl == null
                  ? Icon(
                Icons.person,
                color: Color(0xFF00FF00),
                size: 24.sp,
              )
                  : null,
            ),
          ),
      ],
    );
  }
}