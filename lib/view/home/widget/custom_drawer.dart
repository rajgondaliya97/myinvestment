import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../view_model/auth_provider.dart';
import '../../profile/screen/profile_screen.dart';
import '../screen/home_screen.dart';
import 'drawer_menuItem.dart';

class CustomDrawer extends StatelessWidget {
  final String currentRoute;

  const CustomDrawer({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Drawer(
      backgroundColor: Color(0xFF1A1A1A),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header with User Info
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF00FF00).withOpacity(0.2),
                    Color(0xFF00CC00).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF2A2A2A),
                    width: 1.w,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image
                  Container(
                    width: 70.w,
                    height: 70.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xFF00FF00),
                        width: 3.w,
                      ),
                      color: Color(0xFF2A2A2A),
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
                      size: 35.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // User Name
                  AppText.large(
                    user?['name'] ?? 'User',
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 4.h),
                  // User Email
                  AppText.small(
                    user?['email'] ?? 'user@example.com',
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                children: [
                  DrawerMenuItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    isSelected: currentRoute == 'home',
                    onTap: () {
                      Navigator.pop(context);
                      if (currentRoute != 'home') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => HomeScreen()),
                        );
                      }
                    },
                  ),
                  DrawerMenuItem(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    isSelected: currentRoute == 'profile',
                    onTap: () {
                      Navigator.pop(context);
                      if (currentRoute != 'profile') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => ProfileScreen()),
                        );
                      }
                    },
                  ),
                  DrawerMenuItem(
                    icon: Icons.history,
                    title: 'Investment History',
                    isSelected: currentRoute == 'history',
                    onTap: () {
                      Navigator.pop(context);
                      if (currentRoute != 'history') {
                        /*Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => InvestmentHistoryScreen()),
                        );*/
                      }
                    },
                  ),
                  Divider(
                    color: Color(0xFF2A2A2A),
                    thickness: 1,
                    height: 32.h,
                  ),
                  DrawerMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to settings
                    },
                  ),
                  DrawerMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to help
                    },
                  ),
                ],
              ),
            ),

            // Logout Button
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFF2A2A2A),
                    width: 1.w,
                  ),
                ),
              ),
              child: AppButton.outlined(
                onPressed: () {
                  Navigator.pop(context);
                  authProvider.logout();
                },
                text: 'Logout',
                icon: Icons.logout,
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
