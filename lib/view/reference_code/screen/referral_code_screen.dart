import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/res/app_widget/custom_app_button.dart';
import 'package:myinvestment/res/app_widget/custom_app_text.dart';
import 'package:myinvestment/res/app_widget/custom_app_bar.dart';
import 'package:myinvestment/utils/app_color.dart';
import 'package:share_plus/share_plus.dart';

import '../../home/widget/custom_drawer.dart';

class ReferralCodeScreen extends StatefulWidget {
  const ReferralCodeScreen({Key? key}) : super(key: key);

  @override
  State<ReferralCodeScreen> createState() => _ReferralCodeScreenState();
}

class _ReferralCodeScreenState extends State<ReferralCodeScreen> {
  final String referralCode = "INV2024XYZ";
  bool isCopied = false;

  // 25-level referral system data
  int currentLevel = 1;
  int totalReferrals = 0;
  double totalEarnings = 0.0;

  // Sample referral level data (you can fetch this from API)
  List<Map<String, dynamic>> referralLevels = [
    {'level': 1, 'referrals': 12, 'earnings': 2400.0, 'commission': '10%'},
    {'level': 2, 'referrals': 8, 'earnings': 1200.0, 'commission': '8%'},
    {'level': 3, 'referrals': 5, 'earnings': 750.0, 'commission': '6%'},
    {'level': 4, 'referrals': 3, 'earnings': 450.0, 'commission': '5%'},
    {'level': 5, 'referrals': 2, 'earnings': 300.0, 'commission': '4%'},
  ];

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  void _calculateTotals() {
    totalReferrals = referralLevels.fold(
      0,
      (sum, level) => sum + (level['referrals'] as int),
    );
    totalEarnings = referralLevels.fold(
      0.0,
      (sum, level) => sum + (level['earnings'] as double),
    );
  }

  void _copyToClipboard() {
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
    final String message =
        '''
🚀 Start Growing Your USDT with Infinite Wealth 🚀

I’m investing USDT on *Infinite Wealth* and earning returns through short-term investment plans.

💰 Investment Highlights:
• Invest USDT with confidence
• Same-day earning starts
• Guaranteed returns after investment period
• Safe, simple & transparent process

🎁 Use my referral code to unlock exclusive benefits:
👉 Referral Code: $referralCode

📈 Smart investing made easy — grow your wealth without complexity.

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
        title: 'Referral Program',
        showDrawer: false,
        showBackButton: true,
      ),
      drawer: CustomDrawer(currentRoute: 'referral_code'),
      body: Container(
        decoration: BoxDecoration(gradient: AppColor.screenGradientBgColor),
        child: SafeArea(
          child: SingleChildScrollView(
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

                /*      // Overall Stats Card
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: AppColor.glassGradient,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColor.lighterBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      AppText.medium(
                        'Your Total Earnings',
                        color: AppColor.grey300,
                      ),
                      SizedBox(height: 10.h),
                      AppText.large(
                        '₹${totalEarnings.toStringAsFixed(2)}',
                        color: AppColor.white,
                        fontSize: 28,
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Total Referrals', '$totalReferrals'),
                          Container(
                            width: 1,
                            height: 40.h,
                            color: AppColor.grey300.withOpacity(0.3),
                          ),
                          _buildStatItem('Active Levels', '${referralLevels.length}'),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),
*/
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
                            AppText.medium(
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
                        onTap: _copyToClipboard,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColor.primaryGradient,
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

                /*SizedBox(height: 20.h),

                // Level-wise Breakdown
                AppText.medium(
                  'Your Level-wise Earnings',
                  color: AppColor.white,
                ),
                SizedBox(height: 12.h),

                ...referralLevels.map((level) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _buildLevelCard(
                    level: level['level'],
                    referrals: level['referrals'],
                    earnings: level['earnings'],
                    commission: level['commission'],
                  ),
                )).toList(),
*/
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
                  description:
                      'Earn rewards when they make their first investment',
                  icon: Icons.card_giftcard,
                ),
                SizedBox(height: 12.h),

                _buildStepCard(
                  step: '4',
                  title: 'Multi-Level Earnings',
                  description:
                      'Continue earning from their referrals up to 25 levels',
                  icon: Icons.layers,
                ),

                SizedBox(height: 20.h),

                // Share Button
                AppButton.primary(
                  onPressed: _shareReferralCode,
                  text: 'Share Referral Code',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard({
    required int level,
    required int referrals,
    required double earnings,
    required String commission,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
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
            width: 45.w,
            height: 45.w,
            decoration: BoxDecoration(
              gradient: AppColor.primaryGradient,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: AppText.bold(
                'L$level',
                color: AppColor.white,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bold(
                  'Level $level',
                  color: AppColor.white,
                  fontSize: 12,
                  maxLines: 1,
                ),
                SizedBox(height: 4.h),
                AppText.small(
                  '$referrals referrals • $commission commission',
                  color: AppColor.grey300,
                  fontSize: 10,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText.bold(
                '₹${earnings.toStringAsFixed(0)}',
                color: AppColor.success,
                fontSize: 14,
              ),
              SizedBox(height: 2.h),
              AppText.small('earned', color: AppColor.grey300, fontSize: 9),
            ],
          ),
        ],
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        AppText.bold(value, color: AppColor.white, fontSize: 20),
        SizedBox(height: 4.h),
        AppText.small(label, color: AppColor.grey300, fontSize: 11),
      ],
    );
  }
}
