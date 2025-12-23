import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../view_model/auth_provider.dart';
import '../../auth/screen/auth_wrapper.dart';
import '../../crypto/screen/crypto_plan_history_screen.dart';
import '../../deposit/screen/deposit_screen.dart';
import '../../profile/screen/profile_screen.dart';
import '../../usdt/screen/usdt_plan_history_screen.dart';
import '../screen/home_screen.dart';
import 'drawer_menuItem.dart';

class CustomDrawer extends StatefulWidget {
  final String currentRoute;

  const CustomDrawer({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  void initState() {
    super.initState();
    // Load user data from local storage when drawer opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthController>(context, listen: false).loadUserFromStorage();
    });
  }

  void _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: Color(0xFF2A2A2A)),
        ),
        title: AppText.large(
          'Logout',
          fontWeight: FontWeight.w700,
        ),
        content: AppText.medium(
          'Are you sure you want to logout?',
          color: Colors.grey[400],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText.medium(
              'Cancel',
              color: Colors.grey[400],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: AppText.medium(
              'Logout',
              color: Color(0xFF00FF00),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Close drawer first
      Navigator.pop(context);

      // Perform logout
      await Provider.of<AuthController>(context, listen: false).logout();

      // Navigate to auth wrapper (which will show login screen)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => AuthWrapper()),
            (route) => false, // Remove all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.user;

    // Get user name and email from model
    final userName = user?.user?.name ??
        '${user?.user?.firstName ?? ''} ${user?.user?.lastName ?? ''}'.trim();
    final userEmail = user?.user?.email ?? 'user@example.com';
    final profileImage = '';

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
                    child: profileImage != null && profileImage.isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        profileImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: Color(0xFF00FF00),
                            size: 35.sp,
                          );
                        },
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
                    fontSize: 16,
                    userName.isNotEmpty ? userName : 'User',
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 4.h),
                  // User Email
                  AppText.medium(
                    fontSize: 12,
                    userEmail,
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
                    isSelected: widget.currentRoute == 'home',
                    onTap: () {
                      Navigator.pop(context);
                      if (widget.currentRoute != 'home') {
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
                    isSelected: widget.currentRoute == 'profile',
                    onTap: () {
                      Navigator.pop(context);
                      if (widget.currentRoute != 'profile') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => ProfileScreen()),
                        );
                      }
                    },
                  ),
                  DrawerMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Deposit',
                    isSelected: widget.currentRoute == 'deposit',
                    onTap: () {
                      Navigator.pop(context);
                      if (widget.currentRoute != 'deposit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DepositScreen()),
                        );
                      }
                    },
                  ),
                  DrawerMenuItem(
                    icon: Icons.currency_bitcoin,
                    title: 'Crypto Plans',
                    isSelected: widget.currentRoute == 'crypto',
                    onTap: () {
                      Navigator.pop(context);
                      if (widget.currentRoute != 'crypto') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => CryptoPlanHistoryScreen()),
                        );
                      }
                    },
                  ),
                  DrawerMenuItem(
                    icon: Icons.account_balance_wallet,
                    title: 'USDT Plans',
                    isSelected: widget.currentRoute == 'usdt',
                    onTap: () {
                      Navigator.pop(context);
                      if (widget.currentRoute != 'usdt') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => UsdtPlanHistoryScreen()),
                        );
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
                onPressed: () => _handleLogout(context),
                text: 'Logout',
                icon: Icons.logout,
                height: 45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}