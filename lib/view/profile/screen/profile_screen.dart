import 'package:flutter/cupertino.dart';
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
    // Load user data when profile screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthController>(context, listen: false).loadUserFromStorage();
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
    final user = authController.user;

    // Get user details from model
    final profileImage = '';
    final fullName = user?.user?.name ?? '${user?.user?.firstName ?? ''} ${user?.user?.lastName ?? ''}'.trim();
    final email = user?.user?.email ?? 'N/A';
    final phone = user?.user?.phone ?? 'N/A';
    final memberSince = _formatDate(user?.user?.createdAt);
    final referralCode = user?.user?.referralCode ?? 'N/A';
    final walletBalance = user?.user?.walletBalance ?? '0';
    final investmentAmount = user?.user?.investmentAmount ?? '0';
    final isVerified = user?.user?.isVerified == '1' || user?.user?.isVerified == 'true';
    final role = user?.user?.role ?? 'User';
    final country = user?.user?.country ?? 'N/A';
    final lastLogin = _formatFullDate(user?.user?.lastLogin);

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: CustomAppBar(
        title: 'Profile',
        profileImageUrl: profileImage,
        onProfileTap: () {},
      ),
      drawer: CustomDrawer(currentRoute: 'profile'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.secondaryPrimaryColor,
              AppColor.background,
              AppColor.primaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColor.lighterBlue.withOpacity(0.4),
                      AppColor.secondaryPrimaryColor.withOpacity(0.8),
                      AppColor.primaryColor.withOpacity(0.1),
                    ],
                  ),
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
                        ShaderMask(
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
                      ],
                    ),
                    SizedBox(height: 20.h),
                    ProfileInfoRow(
                      label: 'Full Name',
                      value: fullName.isNotEmpty ? fullName : 'N/A',
                      icon: Icons.person_outline,
                    ),
                    Divider(
                      color: AppColor.primaryColor.withOpacity(0.2),
                      height: 32.h,
                    ),
                    ProfileInfoRow(
                      label: 'Email',
                      value: email,
                      icon: Icons.email_outlined,
                    ),
                    Divider(
                      color: AppColor.primaryColor.withOpacity(0.2),
                      height: 32.h,
                    ),
                    ProfileInfoRow(
                      label: 'Phone',
                      value: phone,
                      icon: Icons.phone_outlined,
                    ),
                    Divider(
                      color: AppColor.primaryColor.withOpacity(0.2),
                      height: 32.h,
                    ),
                    ProfileInfoRow(
                      label: 'Country',
                      value: country,
                      icon: Icons.public_outlined,
                    ),
                    Divider(
                      color: AppColor.primaryColor.withOpacity(0.2),
                      height: 32.h,
                    ),
                    ProfileInfoRow(
                      label: 'Role',
                      value: role,
                      icon: Icons.badge_outlined,
                    ),
                    Divider(
                      color: AppColor.primaryColor.withOpacity(0.2),
                      height: 32.h,
                    ),
                    ProfileInfoRow(
                      label: 'Member Since',
                      value: memberSince,
                      icon: Icons.calendar_today_outlined,
                    ),
                    if (lastLogin != 'N/A') ...[
                      Divider(
                        color: AppColor.primaryColor.withOpacity(0.2),
                        height: 32.h,
                      ),
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColor.lighterBlue.withOpacity(0.4),
                      AppColor.secondaryPrimaryColor.withOpacity(0.8),
                      AppColor.primaryColor.withOpacity(0.1),
                    ],
                  ),
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
                      color: AppColor.primaryColor.withOpacity(0.2),
                      height: 32.h,
                    ),
                    ProfileInfoRow(
                      label: 'Investment Amount',
                      value: '\$$investmentAmount',
                      icon: Icons.trending_up_outlined,
                      valueColor: AppColor.info,
                    ),
                    Divider(
                      color: AppColor.primaryColor.withOpacity(0.2),
                      height: 32.h,
                    ),
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
    );
  }
}