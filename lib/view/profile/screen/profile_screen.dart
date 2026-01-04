import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../utils/app_color.dart';
import '../../../view_model/auth_provider.dart';
import '../../home/widget/custom_drawer.dart';
import '../widget/profile_info_row.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(context, listen: false);
      authController.loadUserFromStorage();
      authController.fetchUserProfile(); // Fetch from API
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatFullDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final profileData = authController.profileData;

    // Show loading
    if (authController.isLoading && profileData == null) {
      return Scaffold(
        backgroundColor: AppColor.background,
        appBar: CustomAppBar(title: 'Profile'),
        drawer: CustomDrawer(currentRoute: 'profile'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
              ),
              SizedBox(height: 16.h),
              AppText.medium('Loading profile...', color: Colors.grey[400]),
            ],
          ),
        ),
      );
    }

    // Show error
    if (authController.errorMessage != null && profileData == null) {
      return Scaffold(
        backgroundColor: AppColor.background,
        appBar: CustomAppBar(title: 'Profile'),
        drawer: CustomDrawer(currentRoute: 'profile'),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: Colors.red[400]),
                SizedBox(height: 16.h),
                AppText.medium(
                  authController.errorMessage ?? 'Failed to load profile',
                  color: Colors.grey[400],
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                AppButton.primary(
                  onPressed: () => authController.fetchUserProfile(),
                  text: 'Retry',
                  icon: Icons.refresh,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Get profile data
    final fullName = profileData?.name ??
        '${profileData?.firstName ?? ''} ${profileData?.lastName ?? ''}'.trim();
    final email = profileData?.email ?? 'N/A';
    final phone = profileData?.phone?.toString() ?? 'N/A';
    final memberSince = _formatDate(profileData?.createdAt);
    final referralCode = profileData?.referralCode ?? 'N/A';
    final walletBalance = profileData?.walletBalance?.toString() ?? '0';
    final isVerified = profileData?.isVerified ?? false;
    final role = profileData?.role ?? 'User';
    final country = profileData?.country?.toString() ?? 'N/A';
    final lastLogin = _formatFullDate(profileData?.lastLogin?.toString());

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: CustomAppBar(
        title: 'Profile',
        profileImageUrl: profileData?.profile ?? '',
        onProfileTap: () {},
      ),
      drawer: CustomDrawer(currentRoute: 'profile'),
      body: Container(
        decoration: BoxDecoration(gradient: AppColor.screenGradientBgColor),
        child: RefreshIndicator(
          onRefresh: () => authController.fetchUserProfile(),
          color: AppColor.primaryColor,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                // Personal Information Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: AppColor.cardGradientBgColor,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColor.primaryColor.withOpacity(0.3),
                      width: 1.5.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primaryColor.withOpacity(0.15),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColor.primaryColor.withOpacity(0.3),
                                  AppColor.lighterGreen.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.person_outline,
                              color: AppColor.lighterGreen,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  AppColor.lighterGreen,
                                  AppColor.primaryColor,
                                ],
                              ).createShader(bounds),
                              child: AppText.medium(
                                'Personal Information',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColor.white,
                              ),
                            ),
                          ),
                          if (isVerified)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: AppColor.lighterGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.verified,
                                      color: AppColor.lighterGreen, size: 14.sp),
                                  SizedBox(width: 4.w),
                                  AppText.small(
                                    'Verified',
                                    color: AppColor.lighterGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      ProfileInfoRow(
                        label: 'Full Name',
                        value: fullName.isNotEmpty ? fullName : 'N/A',
                        icon: Icons.person_outline,
                      ),
                      Divider(
                          color: AppColor.primaryColor.withOpacity(0.2), height: 32.h),
                      ProfileInfoRow(
                        label: 'Email',
                        value: email,
                        icon: Icons.email_outlined,
                      ),
                      Divider(
                          color: AppColor.primaryColor.withOpacity(0.2), height: 32.h),
                      ProfileInfoRow(
                        label: 'Phone',
                        value: phone,
                        icon: Icons.phone_outlined,
                      ),
                      Divider(
                          color: AppColor.primaryColor.withOpacity(0.2), height: 32.h),
                      ProfileInfoRow(
                        label: 'Country',
                        value: country,
                        icon: Icons.public_outlined,
                      ),
                      Divider(
                          color: AppColor.primaryColor.withOpacity(0.2), height: 32.h),
                      ProfileInfoRow(
                        label: 'Role',
                        value: role,
                        icon: Icons.badge_outlined,
                      ),
                      Divider(
                          color: AppColor.primaryColor.withOpacity(0.2), height: 32.h),
                      ProfileInfoRow(
                        label: 'Member Since',
                        value: memberSince,
                        icon: Icons.calendar_today_outlined,
                      ),
                      if (lastLogin != 'N/A') ...[
                        Divider(
                            color: AppColor.primaryColor.withOpacity(0.2),
                            height: 32.h),
                        ProfileInfoRow(
                          label: 'Last Login',
                          value: lastLogin,
                          icon: Icons.login_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Financial Information Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: AppColor.cardGradientBgColor,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColor.primaryColor.withOpacity(0.3),
                      width: 1.5.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primaryColor.withOpacity(0.15),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColor.primaryColor.withOpacity(0.3),
                                  AppColor.lighterGreen.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              color: AppColor.lighterGreen,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                AppColor.lighterGreen,
                                AppColor.primaryColor,
                              ],
                            ).createShader(bounds),
                            child: AppText.medium(
                              'Financial Information',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColor.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      ProfileInfoRow(
                        label: 'Wallet Balance',
                        value: '\$$walletBalance',
                        icon: Icons.account_balance_wallet_outlined,
                        valueColor: AppColor.lighterGreen,
                      ),
                      Divider(
                          color: AppColor.primaryColor.withOpacity(0.2), height: 32.h),
                      ProfileInfoRow(
                        label: 'Referral Code',
                        value: referralCode,
                        icon: Icons.card_giftcard_outlined,
                        isCopyable: referralCode != 'N/A',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Action Buttons
                AppButton.primary(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Edit profile coming soon!'),
                        backgroundColor: AppColor.primaryColor,
                      ),
                    );
                  },
                  text: 'Edit Profile',
                  icon: Icons.edit,
                ),
                SizedBox(height: 12.h),
                AppButton.outlined(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Change password coming soon!'),
                        backgroundColor: AppColor.primaryColor,
                      ),
                    );
                  },
                  text: 'Change Password',
                  icon: Icons.lock_outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}