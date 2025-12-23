import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../view_model/auth_provider.dart';
import '../../home/widget/custom_drawer.dart';
import '../widget/profile_info_row.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.user;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        profileImageUrl: user?['profileImage'],
        onProfileTap: () {},
      ),
      drawer: CustomDrawer(currentRoute: 'profile'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Profile Image
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xFF00FF00),
                        width: 3.w,
                      ),
                      color: Color(0xFF1A1A1A),
                    ),
                    child: user?['profileImage'] != null
                        ? ClipOval(
                      child: Image.network(
                        user!['profileImage'],
                        fit: BoxFit.cover,
                      ),
                    )
                        : Icon(
                      Icons.person,
                      color: Color(0xFF00FF00),
                      size: 60.sp,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Color(0xFF00FF00),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Profile Info Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Color(0xFF2A2A2A), width: 1.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.medium(
                    'Personal Information',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 20.h),
                  ProfileInfoRow(
                    label: 'Full Name',
                    value: user?['name'] ?? 'N/A',
                  ),
                  Divider(color: Color(0xFF2A2A2A), height: 32.h),
                  ProfileInfoRow(
                    label: 'Email',
                    value: user?['email'] ?? 'N/A',
                  ),
                  Divider(color: Color(0xFF2A2A2A), height: 32.h),
                  ProfileInfoRow(
                    label: 'Phone',
                    value: '+1 234 567 8900',
                  ),
                  Divider(color: Color(0xFF2A2A2A), height: 32.h),
                  ProfileInfoRow(
                    label: 'Member Since',
                    value: 'January 2024',
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Action Buttons
            AppButton.primary(
              onPressed: () {},
              text: 'Edit Profile',
              icon: Icons.edit,
            ),
            SizedBox(height: 12.h),
            AppButton.outlined(
              onPressed: () {},
              text: 'Change Password',
              icon: Icons.lock_outline,
            ),
          ],
        ),
      ),
    );
  }
}
