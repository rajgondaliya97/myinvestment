import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_widget/custom_app_button.dart';
import '../../../utils/app_widget/custom_app_text.dart';
import '../../../view_model/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppText.medium('Investment Dashboard', fontSize: 18),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 24.sp),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Color(0xFF00FF00), size: 100.sp),
              SizedBox(height: 20.h),
              AppText.large(
                'Welcome, ${authProvider.user?['name'] ?? 'User'}!',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              AppText.regular(
                'You are successfully logged in',
                color: Colors.grey[600],
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              AppButton.primary(
                onPressed: () {},
                text: 'Start Investing',
                icon: Icons.trending_up,
                width: 250,
              ),
              SizedBox(height: 16.h),
              AppButton.outlined(
                onPressed: () {},
                text: 'View Portfolio',
                icon: Icons.pie_chart,
                width: 250,
              ),
            ],
          ),
        ),
      ),
    );
  }
}