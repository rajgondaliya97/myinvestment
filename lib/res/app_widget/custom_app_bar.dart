import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/res/app_widget/custom_app_text.dart';

import '../../utils/app_color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? profileImageUrl;
  final VoidCallback? onProfileTap;
  final bool showLogo;
  final List<Widget>? actions;
  final bool showDrawer; // NEW: Control drawer visibility
  final bool showBackButton; // NEW: Show back button instead of drawer

  const CustomAppBar({
    Key? key,
    this.title,
    this.profileImageUrl,
    this.onProfileTap,
    this.showLogo = true,
    this.actions,
    this.showDrawer = true, // DEFAULT: Show drawer
    this.showBackButton = false, // DEFAULT: Don't show back button
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(70.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColor.primaryGradient,
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: showDrawer
            ? Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white, size: 28.sp),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        )
            : showBackButton
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        )
            : null,
        automaticallyImplyLeading: showBackButton, // Show back button when needed
        toolbarHeight: 70.h,
        title: Row(
          children: [
            if (title != null)
              Expanded(
                child: Text(
                  title ?? '',
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          if (actions != null) ...actions! else AppText.small('')
        ],
      ),
    );
  }
}