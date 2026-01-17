import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/res/app_widget/custom_app_button.dart';
import 'package:myinvestment/res/app_widget/custom_app_text.dart';
import 'package:myinvestment/res/app_widget/custom_app_bar.dart';
import 'package:myinvestment/utils/app_color.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';

import '../../../view_model/auth_provider.dart';
import '../../home/widget/custom_drawer.dart';

class ReferralCodeScreen extends StatefulWidget {
  const ReferralCodeScreen({Key? key}) : super(key: key);

  @override
  State<ReferralCodeScreen> createState() => _ReferralCodeScreenState();
}

class _ReferralCodeScreenState extends State<ReferralCodeScreen> {
  bool isCopied = false;
  String referralCode = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthController>(context, listen: false);

    // Get referral code from profile data
    if (authProvider.profileData?.referralCode != null) {
      setState(() {
        referralCode = authProvider.profileData!.referralCode!;
      });
    } else {
      // Fetch profile if not available
      authProvider.fetchUserProfile().then((_) {
        if (authProvider.profileData?.referralCode != null) {
          setState(() {
            referralCode = authProvider.profileData!.referralCode!;
          });
        }
      });
    }
  }

  void _copyToClipboard() {
    if (referralCode.isEmpty) return;

    Clipboard.setData(ClipboardData(text: referralCode));
    setState(() {
      isCopied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText.medium('Referral code copied!', color: AppColor.white),
        backgroundColor: AppColor.success,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isCopied = false;
        });
      }
    });
  }

  void _shareReferralCode() {
    if (referralCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText.medium('Referral code not available', color: AppColor.white),
          backgroundColor: AppColor.error,
        ),
      );
      return;
    }

    final String message = '''
🚀 Start Growing Your USDT with Infinite Wealth 🚀

I'm investing USDT on *Infinite Wealth* and earning returns through short-term investment plans.

💰 Investment Highlights:
• Invest USDT with confidence
• Same-day earning starts
• Guaranteed returns after investment period
• Safe, simple & transparent process

🎁 Use my referral code to unlock exclusive benefits:
👉 Referral Code: $referralCode

📈 Smart investing made easy – grow your wealth without complexity.

Download Infinite Wealth today and let your USDT work for you!

#InfiniteWealth #USDTInvestment #SmartEarnings #PassiveIncome
''';

    Share.share(message, subject: 'Grow Your USDT with Infinite Wealth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: CustomAppBar(
        title: 'Referral Code',
        showDrawer: true,
      ),
      drawer: CustomDrawer(currentRoute: 'referral_code'),
      body: Consumer<AuthController>(
        builder: (context, authProvider, child) {
          final isLoading = authProvider.isLoading;

          return Container(
            decoration: BoxDecoration(gradient: AppColor.screenGradientBgColor),
            child: SafeArea(
              child: isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: AppColor.primaryColor,
                ),
              )
                  : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColor.primaryGradient,
                            ),
                            child: Icon(
                              Icons.card_giftcard,
                              size: 30.sp,
                              color: AppColor.white,
                            ),
                          ),
                          SizedBox(height: 15.h),
                          AppText.medium(
                            'Invite Friends & Earn',
                            color: AppColor.white,
                            textAlign: TextAlign.center,
                            fontSize: 18,
                          ),
                          SizedBox(height: 10.h),
                          AppText.small(
                            'Share your referral code and earn rewards up to 25 levels deep!',
                            color: AppColor.grey300,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Referral Code Card
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        gradient: AppColor.cardGradientBgColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColor.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          AppText.small(
                            'Your Referral Code',
                            color: AppColor.grey300,
                          ),
                          SizedBox(height: 14.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColor.primaryColor,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                referralCode.isEmpty
                                    ? AppText.small(
                                  'Loading...',
                                  color: AppColor.grey300,
                                )
                                    : AppText.medium(
                                  referralCode,
                                  color: AppColor.white,
                                  letterSpacing: 2,
                                  fontSize: 16,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15.h),
                          GestureDetector(
                            onTap: referralCode.isEmpty ? null : _copyToClipboard,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 32.w,
                                vertical: 14.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: referralCode.isEmpty
                                    ? LinearGradient(
                                  colors: [
                                    AppColor.grey500,
                                    AppColor.grey500,
                                  ],
                                )
                                    : AppColor.primaryGradient,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isCopied ? Icons.check : Icons.copy,
                                    color: AppColor.white,
                                    size: 15.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  AppText.small(
                                    isCopied ? 'Copied!' : 'Copy Code',
                                    color: AppColor.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // 25-Level Referral System Info
                    AppText.medium(
                      '25-Level Referral System',
                      color: AppColor.white,
                      fontSize: 16,
                    ),
                    SizedBox(height: 10.h),

                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        gradient: AppColor.cardGradientBgColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColor.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: AppColor.success,
                                size: 20.sp,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: AppText.small(
                                  'Earn commission from 25 levels of referrals',
                                  color: AppColor.grey300,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          AppText.small(
                            'Higher commission rates for direct referrals, decreasing gradually through deeper levels',
                            color: AppColor.grey300,
                            maxLines: 3,
                            fontSize: 10,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // How it Works Section
                    AppText.medium('How it Works', color: AppColor.white),
                    SizedBox(height: 12.h),

                    _buildStepCard(
                      step: '1',
                      title: 'Share Your Code',
                      description: 'Send your referral code to friends and family',
                      icon: Icons.share,
                    ),
                    SizedBox(height: 12.h),

                    _buildStepCard(
                      step: '2',
                      title: 'They Sign Up',
                      description: 'Your friends register using your code',
                      icon: Icons.person_add,
                    ),
                    SizedBox(height: 12.h),

                    _buildStepCard(
                      step: '3',
                      title: 'Get Rewards',
                      description: 'Earn rewards when they make their first investment',
                      icon: Icons.card_giftcard,
                    ),
                    SizedBox(height: 12.h),

                    _buildStepCard(
                      step: '4',
                      title: 'Multi-Level Earnings',
                      description: 'Continue earning from their referrals up to 25 levels',
                      icon: Icons.layers,
                    ),

                    SizedBox(height: 20.h),

                    // Share Button
                    AppButton.primary(
                      onPressed: referralCode.isEmpty ? () {} : _shareReferralCode,
                      text: 'Share Referral Code',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepCard({
    required String step,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              gradient: AppColor.primaryGradient,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(icon, color: AppColor.white, size: 18.sp),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bold(
                  title,
                  color: AppColor.white,
                  fontSize: 12,
                  maxLines: 1,
                ),
                SizedBox(height: 4.h),
                AppText.small(
                  description,
                  color: AppColor.grey300,
                  maxLines: 2,
                  fontSize: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}