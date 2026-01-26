import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/view/manual_transfer/screen/manual_transfer_screen.dart';
import 'package:provider/provider.dart';
import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../res/services/ReownWalletService.dart';
import '../../../utils/app_color.dart';
import '../../../view_model/auth_provider.dart';
import '../../auth/screen/auth_wrapper.dart';
import '../../deposit/screen/deposit_screen.dart';
import '../../profile/screen/profile_screen.dart';
import '../../reference_code/screen/reference_levels_screen.dart';
import '../../reference_code/screen/referral_code_screen.dart';
import '../../transaction_history/screen/transaction_history_screen.dart';
import '../../user_plan/screen/user_active_plan_screen.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(context, listen: false);

      // Only fetch if profile data is null
      if (authController.profileData == null) {
        authController.fetchUserProfile();
      }
    });
  }

  void _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.secondaryPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: AppColor.primaryColor.withOpacity(0.3)),
        ),
        title: const AppText.large(
          'Logout',
          fontWeight: FontWeight.w700,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText.medium(
              'Are you sure you want to logout?',
              color: AppColor.grey500,
            ),
            SizedBox(height: 12.h),
            Consumer<ReownWalletService>(
              builder: (context, walletService, child) {
                if (walletService.isConnected) {
                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColor.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColor.warning.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColor.warning,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: AppText.small(
                            'Your wallet will be disconnected',
                            color: AppColor.warning,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const AppText.medium(
              'Cancel',
              color: AppColor.grey500,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const AppText.medium(
              'Logout',
              color: AppColor.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: AppColor.secondaryPrimaryColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColor.primaryColor),
                SizedBox(height: 16.h),
                AppText.medium(
                  'Logging out...',
                  color: AppColor.white,
                  fontSize: 14,
                ),
              ],
            ),
          ),
        ),
      );

      try {
        final walletService = Provider.of<ReownWalletService>(context, listen: false);

        if (walletService.isConnected) {
          debugPrint('🔌 [Logout] Disconnecting wallet...');
          await walletService.disconnect(deleteStoredKey: true);
          debugPrint('✅ [Logout] Wallet disconnected successfully');
        }
        Navigator.pop(context);

        await Provider.of<AuthController>(context, listen: false).logout();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AuthWrapper()),
              (route) => false,
        );
      } catch (e) {
        debugPrint('❌ [Logout] Error: $e');
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AuthWrapper()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        // Get profile data first, fallback to user data
        final profileData = authController.profileData;
        final user = authController.user;

        // ✅ FIXED: Use profileData first, then fallback to user data
        final userName = profileData != null
            ? '${profileData.firstName ?? ''} ${profileData.lastName ?? ''}'.trim()
            : (user?.user?.name ??
            '${user?.user?.firstName ?? ''} ${user?.user?.lastName ?? ''}'.trim());

        final userEmail = profileData?.email ??
            user?.user?.email ??
            'user@example.com';

        // Get profile image if available
        final profileImage = profileData?.profile ?? '';

        // Debug prints
        debugPrint('📊 Profile Data: ${profileData?.toJson()}');
        debugPrint('👤 User Name: $userName');
        debugPrint('📧 User Email: $userEmail');

        return Drawer(
          backgroundColor: AppColor.secondaryPrimaryColor,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.secondaryPrimaryColor,
                  AppColor.primaryColor.withOpacity(0.3),
                  AppColor.secondaryPrimaryColor,
                ],
              ),
            ),
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
                          AppColor.primaryColor.withOpacity(0.3),
                          AppColor.secondaryPrimaryColor.withOpacity(0.5),
                          AppColor.primaryColor.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColor.primaryColor.withOpacity(0.2),
                          width: 1.w,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Avatar
                        Container(
                          width: 70.w,
                          height: 70.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                AppColor.primaryColor,
                                AppColor.lighterGreen,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primaryColor.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            margin: EdgeInsets.all(3.w),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.secondaryPrimaryColor,
                            ),
                            child: profileImage.isNotEmpty
                                ? ClipOval(
                              child: Image.network(
                                profileImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    color: AppColor.primaryColor,
                                    size: 35.sp,
                                  );
                                },
                              ),
                            )
                                : Icon(
                              Icons.person,
                              color: AppColor.primaryColor,
                              size: 35.sp,
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // User Name with Gradient
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [AppColor.lighterGreen, AppColor.primaryColor],
                          ).createShader(bounds),
                          child: AppText.large(
                            fontSize: 16,
                            userName.isNotEmpty ? userName : 'User',
                            fontWeight: FontWeight.w700,
                            color: AppColor.white,
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // User Email
                        AppText.medium(
                          fontSize: 12,
                          userEmail,
                          color: AppColor.grey500,
                        ),

                        Consumer<ReownWalletService>(
                          builder: (context, walletService, child) {
                            if (walletService.isConnected) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColor.success.withOpacity(0.3),
                                      AppColor.success.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: AppColor.success.withOpacity(0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8.w,
                                      height: 8.w,
                                      decoration: BoxDecoration(
                                        color: AppColor.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    AppText.small(
                                      'Wallet Connected',
                                      color: AppColor.success,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              );
                            }
                            return SizedBox.shrink();
                          },
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
                                MaterialPageRoute(builder: (context) => HomeScreen()),
                              );
                            }
                          },
                        ),
                        DrawerMenuItem(
                          icon: Icons.person_outline,
                          title: 'Profile',
                          isSelected: widget.currentRoute == 'profile',
                          onTap: () {
                            final navigator = Navigator.of(context);
                            navigator.pop();
                            if (widget.currentRoute != 'profile') {
                              navigator.pushReplacement(
                                MaterialPageRoute(builder: (context) => ProfileScreen()),
                              );
                            }
                          },
                        ),
                        DrawerMenuItem(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Deposit',
                          isSelected: widget.currentRoute == 'deposit',
                          onTap: () {
                            final navigator = Navigator.of(context);
                            navigator.pop();
                            if (widget.currentRoute != 'deposit') {
                              navigator.pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const DepositScreen()),
                              );
                            }
                          },
                        ),
                        DrawerMenuItem(
                          icon: Icons.currency_exchange,
                          title: 'Manual Transfer',
                          isSelected: widget.currentRoute == 'transfer',
                          onTap: () {
                            Navigator.pop(context);
                            if (widget.currentRoute != 'transfer') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ManualTransferScreen()),
                              );
                            }
                          },
                        ),
                        DrawerMenuItem(
                          icon: Icons.trending_up,
                          title: 'My Active Plans',
                          isSelected: widget.currentRoute == 'active_plans',
                          onTap: () {
                            final navigator = Navigator.of(context);
                            navigator.pop();
                            if (widget.currentRoute != 'active_plans') {
                              navigator.pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const UserActivePlansScreen()),
                              );
                            }
                          },
                        ),
                        DrawerMenuItem(
                          icon: Icons.history,
                          title: 'Transaction History',
                          isSelected: widget.currentRoute == 'transactions',
                          onTap: () {
                            final navigator = Navigator.of(context);
                            navigator.pop();
                            if (widget.currentRoute != 'transactions') {
                              navigator.pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const TransactionHistoryScreen()),
                              );
                            }
                          },
                        ),
                        DrawerMenuItem(
                          icon: Icons.groups_outlined,
                          title: 'Reference Levels',
                          isSelected: widget.currentRoute == 'reference_levels',
                          onTap: () {
                            final navigator = Navigator.of(context);
                            navigator.pop();
                            if (widget.currentRoute != 'reference_levels') {
                              navigator.pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const ReferenceLevelsScreen()),
                              );
                            }
                          },
                        ),
                        DrawerMenuItem(
                          icon: Icons.person_add_alt_1_outlined,
                          title: 'Referral Code',
                          isSelected: widget.currentRoute == 'referral_code',
                          onTap: () {
                            final navigator = Navigator.of(context);
                            navigator.pop();
                            if (widget.currentRoute != 'referral_code') {
                              navigator.pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const ReferralCodeScreen()),
                              );
                            }
                          },
                        ),



                        Divider(
                          color: AppColor.primaryColor.withOpacity(0.2),
                          thickness: 1,
                          height: 32.h,
                        ),
                      ],
                    ),
                  ),

                  // Logout Button
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColor.primaryColor.withOpacity(0.1),
                          AppColor.secondaryPrimaryColor.withOpacity(0.5),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      border: Border(
                        top: BorderSide(
                          color: AppColor.primaryColor.withOpacity(0.2),
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
          ),
        );
      },
    );
  }
}