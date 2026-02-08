import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/res/app_widget/custom_app_bar.dart';
import '../../utils/app_color.dart';
import 'package:myinvestment/res/app_widget/custom_app_text.dart';

class InformetiveHomeScreen extends StatefulWidget {
  const InformetiveHomeScreen({super.key});

  @override
  State<InformetiveHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<InformetiveHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColor.screenGradientBgColor,
        ),
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeroSection(),
                SizedBox(height: 6.h),
                _buildWhyChooseSection(),
                SizedBox(height: 6.h),
                _buildSustainableGrowthSection(),
                SizedBox(height: 6.h),
                _buildOurPackagesSection(),
                SizedBox(height: 6.h),
                _buildOurServicesSection(),
                SizedBox(height: 6.h),
                _buildHowItWorksSection(),
                SizedBox(height: 6.h),
                _buildStatisticsSection(),
                SizedBox(height: 6.h),
                _buildFAQSection(),
                SizedBox(height: 6.h),
                _buildUpdatedTestimonialsSection(),
                SizedBox(height: 6.h),
                _buildDiscoverSection(),
                SizedBox(height: 6.h),
                _buildDownloadAppSection(),
                SizedBox(height: 6.h),
                _buildNewsletterSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Hero Section - Inspired by Infinite Wealth UK
  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 600.h,
      child: Stack(
        children: [
          // Large Circular Background Graphic
          Positioned(
            right: -70.w,
            top: 20.h,
            child: Container(
              width: 250.w,
              height: 250.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColor.primaryColor.withOpacity(0.3),
                    AppColor.lighterGreen.withOpacity(0.2),
                    AppColor.primaryColor.withOpacity(0.15),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primaryColor.withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          // Small decorative circle
          Positioned(
            left: -30.w,
            top: 40.h,
            child: Container(
              width: 40.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.white.withOpacity(0.05),
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main Bold Heading
                  AppText(
                    'INVEST WITH',
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: AppColor.white,
                    letterSpacing: 0.3,
                  ),
                  AppText(
                    'CONFIDENCE.',
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: AppColor.white,
                    letterSpacing: 0.3,
                  ),
                  AppText(
                    'TRADE WITH',
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: AppColor.white,
                    letterSpacing: 0.3,
                  ),
                  AppText(
                    'DISCIPLINE.',
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: AppColor.white,
                    letterSpacing: 0.3,
                  ),
                  SizedBox(height: 2.h),
                  // CTA Button with yellow/green color
                  GestureDetector(
                    onTap: () {
                      // Navigate to investment strategies
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primaryColor.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: AppColor.white.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: AppText.bold(
                        'Explore Investment Strategies',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColor.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Stats Counter
                  AppText.large(
                    '1.6M+',
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: AppColor.white,
                  ),
                  SizedBox(height: 3.h),
                  AppText.regular(
                    'Active Investors & Traders Worldwide',
                    fontSize: 12,
                    color: AppColor.grey300,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Why Choose Section - Mission, Vision, Philosophy
  Widget _buildWhyChooseSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      color: AppColor.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green Header
          AppText(
            'WHY CHOOSE INFINITE WEALTH',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColor.primaryColor,
            letterSpacing: 0.5,
          ),
          SizedBox(height: 6.h),
          // Main Heading
          AppText(
            'A Disciplined & Technology-Driven Investment Approach',
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: AppColor.secondaryPrimaryColor,
            maxLines: 5,
          ),
          SizedBox(height: 3.h),
          // Description
          AppText(
            'Infinite Wealth is a UK-based company focused on building long-term financial value through advanced technology, professional market analysis, and structured investment strategies. We prioritize discipline, transparency, and sustainable growth across global markets.',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColor.grey500,
            maxLines: 10,
            textHeight: 1.6,
          ),
          SizedBox(height: 16.h),
          // Our Mission
          AppText(
            'Our Mission',
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColor.secondaryPrimaryColor,
          ),
          SizedBox(height: 6.h),
          AppText(
            'To achieve technological independence in financial markets by developing proprietary software, analytical tools, and disciplined trading strategies that support informed and responsible capital growth.',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColor.grey500,
            maxLines: 8,
            textHeight: 1.6,
          ),
          SizedBox(height: 2.h),
          // Our Vision
          AppText(
            'Our Vision',
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColor.secondaryPrimaryColor,
          ),
          SizedBox(height: 6.h),
          AppText(
            'To become a globally recognized platform for investment and trading, delivering reliable solutions through innovation, professional expertise, and scalable infrastructure.',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColor.grey500,
            maxLines: 8,
            textHeight: 1.6,
          ),
          SizedBox(height: 14.h),
          // CTA Button with green outline
          GestureDetector(
            onTap: () {
              // Navigate to philosophy page
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColor.primaryColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: AppText.bold(
                  'Explore Our Investment Philosophy',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColor.secondaryPrimaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sustainable Growth Section
  Widget _buildSustainableGrowthSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: AppColor.secondaryPrimaryColor,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Icon
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColor.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.analytics_outlined,
                    size: 22.sp,
                    color: AppColor.secondaryPrimaryColor,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              // Right side - Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Sustainable &',
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColor.primaryColor,
                      maxLines: 2,
                    ),
                    AppText(
                      'Scalable Growth',
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColor.primaryColor,
                      maxLines: 2,
                    ),
                    SizedBox(height: 6.h),
                    AppText(
                      'Our strategies are designed to perform across market cycles, emphasizing risk management, consistency, and long-term capital appreciation rather than short-term speculation.',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColor.white,
                      maxLines: 10,
                      textHeight: 1.6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Speak with our team button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  // Navigate to contact/chat
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColor.white,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText.bold(
                        'Speak with our team',
                        fontSize: 11,
                        color: AppColor.white,
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColor.white,
                        size: 12.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Our Packages Section
  Widget _buildOurPackagesSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      color: Color(0xFFF5F5DC), // Beige/cream color
      child: Column(
        children: [
          // Green Header
          AppText(
            'OUR PACKAGES',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColor.primaryColor,
            letterSpacing: 0.5,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          // Main Heading
          AppText(
            'Choose the Right Package',
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: AppColor.secondaryPrimaryColor,
            maxLines: 3,
            textAlign: TextAlign.center,
          ),
          AppText(
            'for You',
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: AppColor.secondaryPrimaryColor,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          AppText.regular(
            'Carefully structured packages designed for growth, discipline, and long-term earning sustainability.',
            fontSize: 11,
            color: AppColor.grey500,
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
          SizedBox(height: 16.h),

          // Standard Package
          _buildPackageCard(
            title: 'Standard Package',
            details: [
              PackageDetail(label: '\$100', value: 'Minimum Investment'),
              PackageDetail(label: '1%', value: 'Daily Earnings'),
              PackageDetail(label: 'Up to 2X', value: 'Return'),
              PackageDetail(label: 'Valid for 200 Days', value: ''),
            ],
            backgroundColor: AppColor.white,
            borderColor: AppColor.primaryColor,
            isPopular: false,
          ),

          SizedBox(height: 16.h),

          // Booster Package - Most Popular
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildPackageCard(
                title: 'Booster Package',
                details: [
                  PackageDetail(label: '5 Directs', value: 'within 200 days'),
                  PackageDetail(label: '1.5%', value: 'Daily Earnings'),
                  PackageDetail(label: 'Up to 2X', value: 'Return'),
                  PackageDetail(
                      label: 'Best balance of growth & performance',
                      value: '',
                      isGreen: true),
                ],
                backgroundColor: AppColor.secondaryPrimaryColor,
                borderColor: AppColor.primaryColor,
                isPopular: true,
                isDark: true,
              ),
              // Most Popular Badge
              Positioned(
                top: -15.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: AppText.bold(
                      'MOST POPULAR',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColor.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Instant Unlock Package
          _buildInstantUnlockCard(),
        ],
      ),
    );
  }

  // Package Card Widget
  Widget _buildPackageCard({
    required String title,
    required List<PackageDetail> details,
    required Color backgroundColor,
    required Color borderColor,
    required bool isPopular,
    bool isDark = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: borderColor,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          AppText(
            title,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColor.white : AppColor.secondaryPrimaryColor,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          SizedBox(height: 16.h),
          // Details
          ...details.map((detail) => Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: detail.value.isEmpty
                ? AppText(
              detail.label,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: detail.isGreen
                  ? AppColor.primaryColor
                  : (isDark ? AppColor.white : AppColor.secondaryPrimaryColor),
              textAlign: TextAlign.center,
              maxLines: 3,
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                AppText(
                  detail.label,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? AppColor.white
                      : AppColor.secondaryPrimaryColor,
                ),
                SizedBox(width: 3.w),
                AppText(
                  detail.value,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? AppColor.white.withOpacity(0.9)
                      : AppColor.grey500,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // Instant Unlock Card Widget
  Widget _buildInstantUnlockCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(35.w),
      decoration: BoxDecoration(
        color: AppColor.secondaryPrimaryColor,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Unlock Icon
          Icon(
            Icons.lock_open_rounded,
            size: 10.sp,
            color: AppColor.primaryColor,
          ),
          SizedBox(height: 6.h),
          // Title
          AppText(
            'Instant Unlock',
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColor.white,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          // Description
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppColor.white,
                height: 1.5,
              ),
              children: [
                TextSpan(text: 'Unlock all benefits instantly with a '),
                TextSpan(
                  text: '\$3000 self top-up',
                  style: TextStyle(
                    color: AppColor.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          // Premium Access Badge
          AppText(
            'PREMIUM ACCESS',
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppColor.primaryColor,
            letterSpacing: 0.5,
          ),
        ],
      ),
    );
  }

  // Our Services Section
  Widget _buildOurServicesSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      color: Color(0xFFF5F5DC), // Beige/cream color
      child: Column(
        children: [
          // Green Header
          AppText(
            'OUR SERVICES',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColor.primaryColor,
            letterSpacing: 0.5,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          // Main Heading
          AppText(
            'Professional Investment &',
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: AppColor.secondaryPrimaryColor,
            maxLines: 3,
            textAlign: TextAlign.center,
          ),
          AppText(
            'Trading Services',
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: AppColor.secondaryPrimaryColor,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),

          // Service Cards
          _buildServiceCard(
            icon: Icons.currency_bitcoin_rounded,
            title: 'Crypto Trading',
            description:
            'AI-powered cryptocurrency trading strategies combining advanced technology with professional market expertise.',
          ),
          SizedBox(height: 6.h),
          _buildServiceCard(
            icon: Icons.trending_up_rounded,
            title: 'Forex Trading',
            description:
            'Access global currency markets with structured forex trading strategies focused on liquidity, risk control, and disciplined execution.',
          ),
          SizedBox(height: 6.h),
          _buildServiceCard(
            icon: Icons.account_balance_rounded,
            title: 'Investment Consulting',
            description:
            'Strategic investment consulting focused on capital preservation, disciplined planning, and long-term wealth creation.',
          ),
          SizedBox(height: 2.h),

          // View All Services Button
          GestureDetector(
            onTap: () {
              // Navigate to all services page
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 40.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: AppColor.secondaryPrimaryColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText.bold(
                    'View All Services',
                    fontSize: 11,
                    color: AppColor.white,
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColor.white,
                    size: 12.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Service Card Widget
  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon with green background
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 30.h),
            decoration: BoxDecoration(
              color: Color(0xFFE8F5E9), // Light green
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF9C4), // Light yellow
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 22.sp,
                  color: AppColor.secondaryPrimaryColor,
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          // Title
          AppText(
            title,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColor.secondaryPrimaryColor,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          // Description
          AppText(
            description,
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColor.grey500,
            textAlign: TextAlign.center,
            maxLines: 10,
            textHeight: 1.6,
          ),
          SizedBox(height: 3.h),
          // More Button
          GestureDetector(
            onTap: () {
              // Navigate to service details
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 32.w,
                vertical: 14.h,
              ),
              decoration: BoxDecoration(
                color: AppColor.black,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText.bold(
                    'More',
                    fontSize: 10,
                    color: AppColor.white,
                  ),
                  SizedBox(width: 4.w),
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Color(0xFFCDDC39), // Yellow-green
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppColor.black,
                      size: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // How It Works Section
  Widget _buildHowItWorksSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      color: AppColor.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'How It Works',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColor.secondaryPrimaryColor,
                      maxLines: 2,
                    ),
                    SizedBox(height: 2.h),
                    AppText(
                      'A simple and transparent process designed for confidence',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColor.grey500,
                      maxLines: 5,
                      textHeight: 1.5,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              // Navigation Arrows
              Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColor.grey300,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColor.grey500,
                      size: 14.sp,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColor.secondaryPrimaryColor,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppColor.secondaryPrimaryColor,
                      size: 14.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Steps - Horizontal Scrollable
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildHowItWorksCard(
                  stepNumber: '01',
                  icon: Icons.person_add_rounded,
                  title: 'Create Account',
                  description:
                  'Register on Infinite Wealth to access our trading and investment platform powered by advanced technology.',
                ),
                SizedBox(width: 3.w),
                _buildHowItWorksCard(
                  stepNumber: '02',
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Deposit Funds',
                  description:
                  'Add funds to your wallet using multiple cryptocurrencies including BTC, ETH, USDT (TRC20).',
                ),
                SizedBox(width: 3.w),
                _buildHowItWorksCard(
                  stepNumber: '03',
                  icon: Icons.show_chart_rounded,
                  title: 'Start Trading',
                  description:
                  'Begin trading with our AI-powered strategies and professional market analysis tools.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // How It Works Card Widget
  Widget _buildHowItWorksCard({
    required String stepNumber,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: 240.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColor.grey300,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with light background
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Color(0xFFE8F5E9), // Light green/blue
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22.sp,
              color: AppColor.secondaryPrimaryColor,
            ),
          ),
          SizedBox(height: 3.h),
          // Title
          AppText(
            title,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColor.secondaryPrimaryColor,
          ),
          SizedBox(height: 6.h),
          // Description
          AppText(
            description,
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: AppColor.grey500,
            maxLines: 10,
            textHeight: 1.6,
          ),
          SizedBox(height: 3.h),
          // Step Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Step ${stepNumber.replaceAll('0', '')}',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColor.secondaryPrimaryColor,
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Color(0xFFCDDC39), // Yellow-green
                  shape: BoxShape.circle,
                ),
                child: AppText(
                  stepNumber,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColor.secondaryPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Statistics Section
  Widget _buildStatisticsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: Color(0xFFF5F5DC), // Beige/cream color
      child: Column(
        children: [
          _buildStatItem('150+', 'Active Investors & Traders'),
          SizedBox(height: 16.h),
          _buildStatItem('12+', 'Years of Market Experience'),
          SizedBox(height: 16.h),
          _buildStatItem('98%', 'Client Retention Rate'),
          SizedBox(height: 16.h),
          _buildStatItem('<3%', 'Average Risk Per Strategy'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        AppText(
          value,
          fontSize: 72,
          fontWeight: FontWeight.w900,
          color: AppColor.primaryColor,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6.h),
        AppText(
          label,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColor.secondaryPrimaryColor,
          textAlign: TextAlign.center,
          maxLines: 3,
        ),
      ],
    );
  }

  // FAQ Section
  Widget _buildFAQSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5F5DC), // Beige
            Color(0xFFFFF9E6), // Light yellow
          ],
        ),
      ),
      child: Column(
        children: [
          // Green Header
          AppText(
            'WE CAN HELP',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColor.primaryColor,
            letterSpacing: 0.5,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          // Main Heading
          AppText(
            'Get The Answers',
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: AppColor.secondaryPrimaryColor,
            textAlign: TextAlign.center,
          ),
          AppText(
            'To Common Questions',
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: AppColor.secondaryPrimaryColor,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          SizedBox(height: 2.h),
          // Support Image Placeholder
          Container(
            width: double.infinity,
            height: 140.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF9C4),
                  Color(0xFFE8F5E9),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.support_agent_rounded,
                size: 50.sp,
                color: AppColor.primaryColor.withOpacity(0.3),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          // FAQ Items
          _buildFAQItem(
            question: 'How do your investment strategies work?',
            answer:
            'Our investment strategies are built on disciplined research, risk management, and long-term planning. We focus on structured asset allocation and data-driven decisions rather than market speculation or short-term trends.',
            isExpanded: true,
          ),
          SizedBox(height: 6.h),
          _buildFAQItem(
            question: 'Is trading suitable for beginners?',
            answer: 'Yes, we provide comprehensive training and support for beginners.',
          ),
          SizedBox(height: 6.h),
          _buildFAQItem(
            question: 'How do you manage risk in volatile markets?',
            answer: 'We use advanced risk management techniques and diversification.',
          ),
          SizedBox(height: 6.h),
          _buildFAQItem(
            question: 'What is the difference between investing and trading?',
            answer: 'Investing is long-term, trading is short-term focused.',
          ),
          SizedBox(height: 6.h),
          _buildFAQItem(
            question: 'Can I speak with an advisor before getting started?',
            answer: 'Yes, our advisors are available to discuss your investment goals.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
    bool isExpanded = false,
  }) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColor.primaryColor,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  question,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColor.secondaryPrimaryColor,
                  maxLines: 5,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExpanded ? Icons.remove : Icons.add,
                  color: AppColor.white,
                  size: 12.sp,
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            SizedBox(height: 6.h),
            AppText(
              answer,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppColor.grey500,
              maxLines: 10,
              textHeight: 1.6,
            ),
          ],
        ],
      ),
    );
  }

  // Updated Testimonials Section
  Widget _buildUpdatedTestimonialsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      color: AppColor.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green Header
          AppText(
            'TESTIMONIAL',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColor.primaryColor,
            letterSpacing: 0.5,
          ),
          SizedBox(height: 6.h),
          // Main Heading
          AppText(
            'See our customers',
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: AppColor.secondaryPrimaryColor,
            maxLines: 2,
          ),
          AppText(
            'kind remarks',
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: AppColor.secondaryPrimaryColor,
          ),
          SizedBox(height: 16.h),
          // View All Button
          GestureDetector(
            onTap: () {
              // Navigate to all reviews
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 32.w,
                vertical: 14.h,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColor.primaryColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: AppText.bold(
                'View All Client Review',
                fontSize: 10,
                color: AppColor.secondaryPrimaryColor,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Testimonial Card
          Container(
            padding: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              color: Color(0xFFF5F5DC).withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Disciplined Investment Approach',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColor.secondaryPrimaryColor,
                  maxLines: 3,
                ),
                SizedBox(height: 16.h),
                // Quote Icon
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.format_quote,
                    size: 22.sp,
                    color: AppColor.white,
                  ),
                ),
                SizedBox(height: 2.h),
                // User Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: AppColor.grey300,
                      child: Icon(
                        Icons.person,
                        size: 22.sp,
                        color: AppColor.grey500,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.bold(
                          'Aarav Mehta',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColor.secondaryPrimaryColor,
                        ),
                        SizedBox(height: 2.h),
                        AppText(
                          'Long-term Investor',
                          fontSize: 10,
                          color: AppColor.grey500,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Testimonial Text
                AppText(
                  '"What impressed me most was their structured and disciplined investment process. Every decision is backed by research and risk management, which gave me confidence even during volatile market phases."',
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: AppColor.secondaryPrimaryColor,
                  maxLines: 15,
                  textHeight: 1.6,
                ),
                SizedBox(height: 3.h),
                // Star Rating
                Row(
                  children: List.generate(
                    5,
                        (index) => Padding(
                      padding: EdgeInsets.only(right: 5.w),
                      child: Icon(
                        Icons.star,
                        color: Color(0xFFFFB300),
                        size: 10.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Trust Badges Section
  Widget _buildTrustBadges() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          AppText.small(
            'TRUSTED BY',
            fontSize: 11,
            color: AppColor.grey500,
            letterSpacing: 0.5,
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTrustBadge('SEBI Registered'),
              _buildTrustBadge('ISO Certified'),
              _buildTrustBadge('256-bit SSL'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: AppText.small(
        text,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColor.white,
      ),
    );
  }

  // Investment Categories Section
  Widget _buildInvestmentCategories() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          AppText.large(
            'Investment Options',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColor.white,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          AppText.regular(
            'Choose from a wide range of investment products',
            fontSize: 9,
            color: AppColor.grey300,
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
          SizedBox(height: 16.h),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 15.w,
            mainAxisSpacing: 15.h,
            childAspectRatio: 1.1,
            children: [
              _buildCategoryCard(
                icon: Icons.show_chart_rounded,
                title: 'Equity Funds',
                description: 'High growth potential',
                color: AppColor.success,
              ),
              _buildCategoryCard(
                icon: Icons.savings_rounded,
                title: 'Debt Funds',
                description: 'Stable returns',
                color: AppColor.info,
              ),
              _buildCategoryCard(
                icon: Icons.pie_chart_rounded,
                title: 'Hybrid Funds',
                description: 'Balanced approach',
                color: AppColor.warning,
              ),
              _buildCategoryCard(
                icon: Icons.rocket_launch_rounded,
                title: 'ELSS',
                description: 'Tax saving',
                color: AppColor.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 11.sp,
            ),
          ),
          SizedBox(height: 2.h),
          AppText.bold(
            title,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColor.white,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          AppText.small(
            description,
            fontSize: 11,
            color: AppColor.grey300,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Features Section
  Widget _buildFeaturesSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          AppText.large(
            'Why Choose Us?',
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColor.white,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          AppText.regular(
            'Everything you need to build wealth',
            fontSize: 11,
            color: AppColor.grey300,
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
          SizedBox(height: 2.h),
          _buildFeatureCard(
            icon: Icons.security_rounded,
            title: 'Bank-Grade Security',
            description:
            'Your investments are protected with multi-layer encryption and secure data storage',
          ),
          SizedBox(height: 6.h),
          _buildFeatureCard(
            icon: Icons.speed_rounded,
            title: 'Lightning Fast Trades',
            description:
            'Execute trades in milliseconds with our high-performance trading infrastructure',
          ),
          SizedBox(height: 6.h),
          _buildFeatureCard(
            icon: Icons.analytics_rounded,
            title: 'Advanced Analytics',
            description:
            'Make informed decisions with real-time market data and comprehensive analysis tools',
          ),
          SizedBox(height: 6.h),
          _buildFeatureCard(
            icon: Icons.people_rounded,
            title: 'Expert Support 24/7',
            description:
            'Our dedicated team of investment advisors is available round the clock to assist you',
          ),
        ],
      ),
    );
  }

  // Stats Section
  Widget _buildStatsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primaryColor.withOpacity(0.15),
            AppColor.secondaryPrimaryColor.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          AppText.large(
            'Trusted Worldwide',
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColor.white,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          _buildStatItem1('50K+', 'Active Users', Icons.people_rounded),
          SizedBox(height: 3.h),
          Divider(
            color: AppColor.primaryColor.withOpacity(0.3),
            thickness: 1,
          ),
          SizedBox(height: 3.h),
          _buildStatItem1('₹500Cr+', 'Assets Under Management', Icons.account_balance_rounded),
          SizedBox(height: 3.h),
          Divider(
            color: AppColor.primaryColor.withOpacity(0.3),
            thickness: 1,
          ),
          SizedBox(height: 3.h),
          _buildStatItem1('4.8★', 'App Rating', Icons.star_rounded),
        ],
      ),
    );
  }

  // Why Choose Us Section
  Widget _buildWhyChooseUsSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          AppText.large(
            'Investment Made Simple',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColor.white,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          _buildInfoCard(
            number: '01',
            title: 'Create Account',
            description:
            'Sign up in minutes with your basic details and complete KYC verification',
          ),
          SizedBox(height: 6.h),
          _buildInfoCard(
            number: '02',
            title: 'Choose Funds',
            description:
            'Browse through curated mutual funds based on your goals and risk appetite',
          ),
          SizedBox(height: 6.h),
          _buildInfoCard(
            number: '03',
            title: 'Start Investing',
            description:
            'Invest via lumpsum or SIP and track your portfolio growth in real-time',
          ),
        ],
      ),
    );
  }

  // Testimonials Section
  Widget _buildTestimonialsSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          AppText.large(
            'What Our Investors Say',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColor.white,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          _buildTestimonialCard(
            name: 'Priya Sharma',
            role: 'Software Engineer',
            rating: 5,
            testimonial:
            'The best investment platform I\'ve used. Easy to understand and great returns on my SIPs!',
          ),
          SizedBox(height: 6.h),
          _buildTestimonialCard(
            name: 'Rahul Patel',
            role: 'Business Owner',
            rating: 5,
            testimonial:
            'Excellent customer support and transparent fee structure. Highly recommended for beginners.',
          ),
          SizedBox(height: 6.h),
          _buildTestimonialCard(
            name: 'Anjali Desai',
            role: 'Marketing Manager',
            rating: 5,
            testimonial:
            'Started investing 6 months ago and already seeing good growth. The app makes it so simple!',
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard({
    required String name,
    required String role,
    required int rating,
    required String testimonial,
  }) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: AppColor.primaryColor.withOpacity(0.3),
                child: Icon(
                  Icons.person,
                  color: AppColor.primaryColor,
                  size: 10.sp,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bold(
                      name,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColor.white,
                      maxLines: 1,
                    ),
                    SizedBox(height: 2.h),
                    AppText.small(
                      role,
                      fontSize: 12,
                      color: AppColor.grey300,
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  rating,
                      (index) => Icon(
                    Icons.star_rounded,
                    color: AppColor.warning,
                    size: 11.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          AppText.regular(
            testimonial,
            fontSize: 9,
            color: AppColor.grey300,
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  // CTA Section
  Widget _buildCTASection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primaryColor,
            AppColor.lighterGreen,
            AppColor.primaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.4),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          AppText(
            'START YOUR',
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColor.white,
            textAlign: TextAlign.center,
            letterSpacing: 0.5,
          ),
          AppText(
            'INVESTMENT JOURNEY',
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColor.white,
            textAlign: TextAlign.center,
            letterSpacing: 0.5,
          ),
          SizedBox(height: 6.h),
          AppText.regular(
            'Join thousands of investors building wealth with confidence',
            fontSize: 11,
            color: AppColor.white.withOpacity(0.95),
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
          SizedBox(height: 2.h),
          GestureDetector(
            onTap: () {
              // Navigate to registration
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColor.secondaryPrimaryColor,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: AppText.bold(
                  'Open Free Account',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColor.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Feature Card Widget
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient: AppColor.primaryGradient,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: AppColor.white,
              size: 10.sp,
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bold(
                  title,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.white,
                  maxLines: 2,
                ),
                SizedBox(height: 3.h),
                AppText.regular(
                  description,
                  fontSize: 9,
                  color: AppColor.grey300,
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Stat Item Widget
  Widget _buildStatItem1(String value, String label, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            gradient: AppColor.primaryGradient,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            color: AppColor.white,
            size: 10.sp,
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.large(
                value,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColor.primaryColor,
              ),
              SizedBox(height: 2.h),
              AppText.small(
                label,
                fontSize: 9,
                color: AppColor.grey300,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Info Card Widget
  Widget _buildInfoCard({
    required String number,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              gradient: AppColor.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppText.bold(
                number,
                fontSize: 9,
                color: AppColor.white,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bold(
                  title,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.white,
                  maxLines: 2,
                ),
                SizedBox(height: 3.h),
                AppText.regular(
                  description,
                  fontSize: 9,
                  color: AppColor.grey300,
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Discover Section - Promotional Offers
  Widget _buildDiscoverSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      color: AppColor.white,
      child: Column(
        children: [
          // Header with arrows and button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Navigation Arrows
              Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColor.secondaryPrimaryColor,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColor.secondaryPrimaryColor,
                      size: 10.sp,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColor.secondaryPrimaryColor,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppColor.secondaryPrimaryColor,
                      size: 10.sp,
                    ),
                  ),
                ],
              ),
              // Find Out More Button
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 28.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColor.primaryColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: AppText.bold(
                    'Find Out More',
                    fontSize: 9,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Discover Title
          Align(
            alignment: Alignment.centerLeft,
            child: AppText(
              'Discover',
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: AppColor.secondaryPrimaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          // Promotional Cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPromoCard(
                  title: 'Get \$5 instantly',
                  subtitle: 'Top Up \$100, Get \$5 Instantly',
                  description: 'Instant bonus on first top-up',
                  imageGradient: LinearGradient(
                    colors: [
                      Color(0xFF00BFA5),
                      Color(0xFF0288D1),
                    ],
                  ),
                ),
                SizedBox(width: 3.w),
                _buildPromoCard(
                  title: 'Top Up Bonus (Up to 599\$)',
                  subtitle: 'Direct Downline Bonus',
                  description:
                  'Direct Downlines Initial Top Up, Upline get rewards up to \$599',
                  views: '201311',
                  date: '05/10/2024',
                  imageGradient: LinearGradient(
                    colors: [
                      Color(0xFF1976D2),
                      Color(0xFF0097A7),
                    ],
                  ),
                ),
                SizedBox(width: 3.w),
                _buildPromoCard(
                  title: 'up to \$27000',
                  subtitle: 'Mega Bonus',
                  description: 'Earn up to \$27000 in rewards',
                  imageGradient: LinearGradient(
                    colors: [
                      Color(0xFF00897B),
                      Color(0xFF0288D1),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard({
    required String title,
    required String subtitle,
    required String description,
    required LinearGradient imageGradient,
    String? views,
    String? date,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Container(
            width: double.infinity,
            height: 100.h,
            decoration: BoxDecoration(
              gradient: imageGradient,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24.r),
              ),
            ),
            child: Stack(
              children: [
                // Decorative elements
                Positioned(
                  top: 20.h,
                  right: 20.w,
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30.h,
                  left: 30.w,
                  child: Container(
                    width: 30.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Center(
                  child: AppText(
                    title,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColor.white,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Content Section
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  subtitle,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: views != null
                      ? AppColor.primaryColor
                      : AppColor.secondaryPrimaryColor,
                  maxLines: 2,
                ),
                SizedBox(height: 2.h),
                AppText(
                  description,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: AppColor.grey500,
                  maxLines: 5,
                ),
                if (views != null && date != null) ...[
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 11.sp,
                            color: AppColor.grey500,
                          ),
                          SizedBox(width: 2.w),
                          AppText(
                            views,
                            fontSize: 9,
                            color: AppColor.grey500,
                          ),
                        ],
                      ),
                      AppText(
                        date,
                        fontSize: 9,
                        color: AppColor.grey500,
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 28.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.secondaryPrimaryColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: AppText.bold(
                        'Read More',
                        fontSize: 9,
                        color: AppColor.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Download App Section
  Widget _buildDownloadAppSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.secondaryPrimaryColor,
            AppColor.primaryColor,
          ],
        ),
      ),
      child: Column(
        children: [
          // Phone Mockup with decorative elements
          Container(
            width: 160.w,
            height: 100.h,
            decoration: BoxDecoration(
              color: AppColor.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Stack(
              children: [
                // Decorative icons
                Positioned(
                  top: 40.h,
                  right: 20.w,
                  child: Icon(
                    Icons.phone_android,
                    size: 30.sp,
                    color: AppColor.white.withOpacity(0.3),
                  ),
                ),
                Positioned(
                  top: 120.h,
                  left: 20.w,
                  child: Icon(
                    Icons.star,
                    size: 25.sp,
                    color: Color(0xFFFFD700).withOpacity(0.6),
                  ),
                ),
                Positioned(
                  bottom: 120.h,
                  right: 30.w,
                  child: Icon(
                    Icons.rocket_launch,
                    size: 10.sp,
                    color: Colors.orange.withOpacity(0.6),
                  ),
                ),
                Positioned(
                  bottom: 60.h,
                  left: 30.w,
                  child: Icon(
                    Icons.diamond,
                    size: 14.sp,
                    color: Colors.blue.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          // New Version Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 10.h,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.secondaryPrimaryColor,
                  AppColor.primaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFFFD700),
                  size: 11.sp,
                ),
                SizedBox(width: 3.w),
                AppText.bold(
                  'New Version Available',
                  fontSize: 9,
                  color: AppColor.white,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Heading
          AppText(
            'Download Our',
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: AppColor.white,
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                'Amazing ',
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: AppColor.white,
              ),
              AppText(
                'App',
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: AppColor.primaryColor,
              ),
            ],
          ),
          SizedBox(height: 6.h),
          // Description
          AppText(
            'Experience the future of mobile applications. Fast, secure, and designed for you. Available on Android devices.',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColor.white.withOpacity(0.9),
            textAlign: TextAlign.center,
            maxLines: 10,
            textHeight: 1.6,
          ),
          SizedBox(height: 2.h),
          // Features
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAppFeature(Icons.flash_on, 'Lightning Fast'),
              _buildAppFeature(Icons.lock_outline, 'Secure & Private'),
            ],
          ),
          SizedBox(height: 6.h),
          _buildAppFeature(Icons.palette_outlined, 'Beautiful Design'),
          SizedBox(height: 2.h),
          // Download Button
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 40.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.secondaryPrimaryColor,
                    AppColor.primaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.download,
                    color: AppColor.white,
                    size: 14.sp,
                  ),
                  SizedBox(width: 2.w),
                  AppText.bold(
                    'Click Here to Download',
                    fontSize: 11,
                    color: AppColor.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppFeature(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Color(0xFFFFD700),
          size: 14.sp,
        ),
        SizedBox(width: 4.w),
        AppText.bold(
          label,
          fontSize: 11,
          color: AppColor.white,
        ),
      ],
    );
  }

  // Newsletter Section with Footer
  Widget _buildNewsletterSection() {
    return Container(
      width: double.infinity,
      color: AppColor.secondaryPrimaryColor,
      child: Column(
        children: [
          // Newsletter Subscription
          Container(
            margin: EdgeInsets.all(10.w),
            padding: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              children: [
                AppText(
                  'STAY INFORMED',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primaryColor,
                  letterSpacing: 0.5,
                ),
                SizedBox(height: 6.h),
                AppText(
                  'Subscribe for market insights, investment strategies & updates',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColor.secondaryPrimaryColor,
                  textAlign: TextAlign.center,
                  maxLines: 5,
                ),
                SizedBox(height: 16.h),
                // Email Input with Subscribe Button
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'you@example.com',
                            hintStyle: TextStyle(
                              color: AppColor.grey500,
                              fontSize: 11.sp,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 12.h,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w,
                            vertical: 16.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColor.secondaryPrimaryColor,
                                AppColor.primaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              AppText.bold(
                                'Subscribe',
                                fontSize: 10,
                                color: AppColor.white,
                              ),
                              SizedBox(width: 3.w),
                              Icon(
                                Icons.arrow_forward,
                                color: AppColor.white,
                                size: 11.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Footer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo and Description
                Row(
                  children: [
                    Icon(
                      Icons.shield,
                      color: AppColor.primaryColor,
                      size: 22.sp,
                    ),
                    SizedBox(width: 2.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Infinite',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColor.white,
                        ),
                        AppText(
                          'wealth',
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: AppColor.white,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                AppText(
                  'We provide disciplined investment strategies and data-driven trading solutions focused on long-term wealth creation and capital preservation.',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: AppColor.white.withOpacity(0.8),
                  maxLines: 10,
                  textHeight: 1.6,
                ),
                SizedBox(height: 2.h),
                // Social Media Icons
                Row(
                  children: [
                    _buildSocialIcon(Icons.flutter_dash), // Twitter placeholder
                    SizedBox(width: 6.w),
                    _buildSocialIcon(Icons.photo_camera), // Instagram placeholder
                    SizedBox(width: 6.w),
                    _buildSocialIcon(Icons.email),
                  ],
                ),
                SizedBox(height: 16.h),
                // Quick Links Section
                AppText(
                  'Quick Links',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primaryColor,
                ),
                SizedBox(height: 6.h),
                _buildFooterLink('Home'),
                SizedBox(height: 2.h),
                _buildFooterLink('About Us'),
                SizedBox(height: 2.h),
                _buildFooterLink('Services'),
                SizedBox(height: 2.h),
                _buildFooterLink('Contact'),
                SizedBox(height: 2.h),
                // Company Section
                AppText(
                  'Company',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primaryColor,
                ),
                SizedBox(height: 6.h),
                _buildFooterLink('Terms & Conditions'),
                SizedBox(height: 2.h),
                _buildFooterLink('Compensation Plan'),
                SizedBox(height: 2.h),
                _buildFooterLink('Privacy Policy'),
                SizedBox(height: 2.h),
                _buildFooterLink('FAQ'),
                SizedBox(height: 2.h),
                // Contact Us Section
                AppText(
                  'Contact Us',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primaryColor,
                ),
                SizedBox(height: 6.h),
                AppText(
                  '500 E Las Olas Blvd, Suite 319',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColor.white.withOpacity(0.9),
                ),
                SizedBox(height: 3.h),
                AppText(
                  'Fort Lauderdale, FL 33301',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColor.white.withOpacity(0.9),
                ),
                SizedBox(height: 6.h),
                GestureDetector(
                  onTap: () {
                    // Open email
                  },
                  child: AppText(
                    'info@infinitewealth.uk',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColor.white,
                  ),
                ),
                SizedBox(height: 2.h),
                GestureDetector(
                  onTap: () {
                    // Open phone
                  },
                  child: AppText(
                    '+91 12345 67890',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColor.white,
                  ),
                ),
                SizedBox(height: 16.h),
                // Divider
                Container(
                  height: 1,
                  color: AppColor.white.withOpacity(0.2),
                ),
                SizedBox(height: 16.h),
                // Copyright
                Center(
                  child: AppText(
                    '© Infinite Wealth 2026 . All rights reserved.',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColor.white.withOpacity(0.7),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return GestureDetector(
      onTap: () {
        // Handle social media link
      },
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: AppColor.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColor.white,
          size: 14.sp,
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {
        // Handle navigation
      },
      child: AppText(
        text,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColor.white.withOpacity(0.9),
      ),
    );
  }
}


// Helper class for package details
class PackageDetail {
  final String label;
  final String value;
  final bool isGreen;

  PackageDetail({
    required this.label,
    this.value = '',
    this.isGreen = false,
  });
}