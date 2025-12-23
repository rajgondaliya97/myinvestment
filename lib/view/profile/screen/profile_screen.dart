import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_text.dart';
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
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        title: 'Profile',
        profileImageUrl: profileImage,
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
                    child: profileImage != null && profileImage.isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        profileImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: Color(0xFF00FF00),
                            size: 60.sp,
                          );
                        },
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
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Implement image picker
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Image upload coming soon!'),
                            backgroundColor: Color(0xFF00FF00).withOpacity(0.8),
                          ),
                        );
                      },
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
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Verification Badge
            if (isVerified)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Color(0xFF00FF00).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Color(0xFF00FF00)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: Color(0xFF00FF00), size: 16.sp),
                    SizedBox(width: 4.w),
                    AppText.small('Verified Account', color: Color(0xFF00FF00)),
                  ],
                ),
              ),
            SizedBox(height: 24.h),

            // Personal Information Card
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
                    value: fullName.isNotEmpty ? fullName : 'N/A',
                    icon: Icons.person_outline,
                  ),
                  Divider(color: Color(0xFF2A2A2A), height: 32.h),
                  ProfileInfoRow(
                    label: 'Email',
                    value: email,
                    icon: Icons.email_outlined,
                  ),
                  Divider(color: Color(0xFF2A2A2A), height: 32.h),
                  ProfileInfoRow(
                    label: 'Phone',
                    value: phone,
                    icon: Icons.phone_outlined,
                  ),
                  Divider(color: Color(0xFF2A2A2A), height: 32.h),
                  ProfileInfoRow(
                    label: 'Country',
                    value: country,
                    icon: Icons.public_outlined,
                  ),
                  Divider(color: Color(0xFF2A2A2A), height: 32.h),
                  ProfileInfoRow(
                    label: 'Role',
                    value: role,
                    icon: Icons.badge_outlined,
                  ),
                  Divider(color: Color(0xFF2A2A2A), height: 32.h),
                  ProfileInfoRow(
                    label: 'Member Since',
                    value: memberSince,
                    icon: Icons.calendar_today_outlined,
                  ),
                  if (lastLogin != 'N/A') ...[
                    Divider(color: Color(0xFF2A2A2A), height: 32.h),
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
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Color(0xFF2A2A2A), width: 1.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.medium(
                    'Financial Information',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 20.h),
                  ProfileInfoRow(
                    label: 'Wallet Balance',
                    value: '\$$walletBalance',
                    icon: Icons.account_balance_wallet_outlined,
                    valueColor: Color(0xFF00FF00),
                  ),
                  Divider(color: Color(0xFF2A2A2A), height: 32.h),
                  ProfileInfoRow(
                    label: 'Investment Amount',
                    value: '\$$investmentAmount',
                    icon: Icons.trending_up_outlined,
                    valueColor: Colors.blue,
                  ),
                  Divider(color: Color(0xFF2A2A2A), height: 32.h),
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
                // TODO: Implement edit profile
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Edit profile coming soon!'),
                    backgroundColor: Color(0xFF00FF00).withOpacity(0.8),
                  ),
                );
              },
              text: 'Edit Profile',
              icon: Icons.edit,
            ),
            SizedBox(height: 12.h),
            AppButton.outlined(
              onPressed: () {
                // TODO: Implement change password
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Change password coming soon!'),
                    backgroundColor: Color(0xFF00FF00).withOpacity(0.8),
                  ),
                );
              },
              text: 'Change Password',
              icon: Icons.lock_outline,
            ),
          ],
        ),
      ),
    );
  }
}