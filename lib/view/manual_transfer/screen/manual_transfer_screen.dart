import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../utils/app_color.dart';
import '../../../utils/app_constent.dart';
import '../../home/widget/custom_drawer.dart';

class ManualTransferScreen extends StatefulWidget {
  const ManualTransferScreen({super.key});

  @override
  State<ManualTransferScreen> createState() => _ManualTransferScreenState();
}

class _ManualTransferScreenState extends State<ManualTransferScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isCopied = false;

  final String supportEmail = 'info@infinitewealth.uk';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _isCopied = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppColor.white, size: 20.sp),
            SizedBox(width: 12.w),
            const Text('Address copied successfully!'),
          ],
        ),
        backgroundColor: AppColor.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  Future<void> _openEmailApp() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: 'subject=Manual Transfer Support Request&body=Hello,%0D%0A%0D%0AI need assistance with my manual transfer.%0D%0A%0D%0ATransaction Details:%0D%0A- Transaction Hash: %0D%0A- Amount: %0D%0A- Investment Plan: %0D%0A%0D%0AThank you.',
    );

    try {
      final bool canLaunch = await canLaunchUrl(emailUri);

      if (canLaunch) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: Copy email address and show dialog
        if (mounted) {
          _showEmailFallbackDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        _showEmailFallbackDialog();
      }
    }
  }

  void _showEmailFallbackDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.secondaryPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: AppColor.primaryColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.email_outlined, color: AppColor.lighterGreen, size: 24.sp),
              SizedBox(width: 12.w),
              AppText.bold(
                'Contact Support',
                color: AppColor.white,
                fontSize: 16,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.small(
                'No email app found. Copy the email address below and contact us:',
                color: AppColor.grey300,
                maxLines: 3,
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColor.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColor.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppText.small(
                        supportEmail,
                        color: AppColor.lighterGreen,
                        fontSize: 13,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy, color: AppColor.white, size: 18.sp),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: supportEmail));
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: AppColor.white, size: 20.sp),
                                SizedBox(width: 12.w),
                                const Text('Email address copied!'),
                              ],
                            ),
                            backgroundColor: AppColor.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            margin: EdgeInsets.all(16.w),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: AppText.medium(
                'Close',
                color: AppColor.primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const platformAddress = '0x42Ac3E3A8D908bbc959408f1266b4489a7FC5Cbe';

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: CustomAppBar(title: 'Manual Transfer'),
      drawer: CustomDrawer(currentRoute: 'transfer'),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColor.screenGradientBgColor,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Glassmorphic Info Card
                  _buildInfoCard(),

                  SizedBox(height: 28.h),

                  // Address Section with Modern Card
                  _buildAddressSection(context, platformAddress),

                  SizedBox(height: 32.h),

                  // Steps Section with Modern Design
                  _buildStepsSection(context),

                  SizedBox(height: 32.h),

                  // Support Card with Gradient
                  _buildSupportCard(),

                  SizedBox(height: 24.h),

                  // Warning Card with Enhanced Design
                  _buildWarningCard(),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.info.withOpacity(0.15),
            AppColor.secondaryPrimaryColor.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColor.info.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.info.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.info.withOpacity(0.3),
                  AppColor.info.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: AppColor.info,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: AppText.small(
              'Transfer USDT manually to our platform address and contact support to activate your investment plan.',
              color: AppColor.grey300,
              maxLines: 5,
              fontSize: 13,
              textHeight: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context, String platformAddress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bold(
                  'Wallet Address',
                  fontSize: 16,
                  color: AppColor.white,
                ),
                SizedBox(height: 4.h),
                AppText.small(
                  'BEP-20 Network',
                  color: AppColor.grey500,
                  fontSize: 11,
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.success.withOpacity(0.3),
                    AppColor.success.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColor.success.withOpacity(0.6),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: AppColor.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.success.withOpacity(0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AppText.small(
                    'BSC Network',
                    color: AppColor.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // Modern Address Card
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColor.secondaryPrimaryColor.withOpacity(0.6),
                AppColor.lighterBlue.withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColor.lighterGreen.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.primaryColor.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Address Display
              Container(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    // Wrapped the Icon in an InkWell to make it clickable
                    InkWell(
                      onTap: () => _showQRCodeDialog(context, platformAddress),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        child: Icon(
                          Icons.qr_code_2_rounded,
                          color: AppColor.lighterGreen.withOpacity(0.7),
                          size: 32.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: AppText.small(
                        platformAddress,
                        color: AppColor.lighterGreen,
                        maxLines: 2,
                        letterSpacing: 0.3,
                        fontSize: 12,
                        textHeight: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider with gradient
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColor.primaryColor.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Copy Button
              InkWell(
                onTap: () => _copyToClipboard(context, platformAddress),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          _isCopied ? Icons.check_circle_rounded : Icons.content_copy_rounded,
                          key: ValueKey(_isCopied),
                          color: _isCopied ? AppColor.success : AppColor.white,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      AppText.medium(
                        _isCopied ? 'Copied!' : 'Copy Address',
                        color: _isCopied ? AppColor.success : AppColor.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 24.h,
              decoration: BoxDecoration(
                gradient: AppColor.primaryGradient,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 12.w),
            AppText.bold(
              'Transfer Steps',
              fontSize: 16,
              color: AppColor.white,
            ),
          ],
        ),

        SizedBox(height: 20.h),

        // Steps with modern cards
        _buildModernStepItem(
          context,
          step: 1,
          icon: Icons.copy_all_rounded,
          title: 'Copy Address',
          description: 'Copy the platform wallet address above',
          color: AppColor.info,
        ),

        _buildModernStepItem(
          context,
          step: 2,
          icon: Icons.send_rounded,
          title: 'Send USDT',
          description: 'Transfer USDT (BEP-20) from your wallet',
          color: AppColor.primaryColor,
        ),

        _buildModernStepItem(
          context,
          step: 3,
          icon: Icons.bookmark_rounded,
          title: 'Save Transaction',
          description: 'Keep your transaction hash safe',
          color: AppColor.warning,
        ),

        _buildModernStepItem(
          context,
          step: 4,
          icon: Icons.support_agent_rounded,
          title: 'Contact Support',
          description: 'Share details with our support team',
          color: AppColor.success,
          isLast: true,
          subItems: [
            'Transaction hash',
            'Amount transferred',
            'Selected investment plan',
          ],
        ),
      ],
    );
  }

  Widget _buildModernStepItem(
      BuildContext context, {
        required int step,
        required IconData icon,
        required String title,
        required String description,
        required Color color,
        bool isLast = false,
        List<String>? subItems,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator column
          Column(
            children: [
              // Step circle
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withOpacity(0.6),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: AppColor.white,
                  size: 20.sp,
                ),
              ),
              // Connecting line
              if (!isLast)
                Container(
                  width: 2.w,
                  height: subItems != null ? 80.h : 50.h,
                  margin: EdgeInsets.symmetric(vertical: 4.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withOpacity(0.5),
                        color.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(width: 16.w),

          // Content
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.1),
                    AppColor.secondaryPrimaryColor.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppText.bold(
                        'Step $step',
                        fontSize: 11,
                        color: color,
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 4.w,
                        height: 4.w,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: AppText.bold(
                          title,
                          fontSize: 14,
                          color: AppColor.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  AppText.small(
                    description,
                    color: AppColor.grey300,
                    fontSize: 12,
                    textHeight: 1.4,
                  ),
                  if (subItems != null) ...[
                    SizedBox(height: 12.h),
                    ...subItems.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withOpacity(0.5)],
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: AppText.small(
                              item,
                              color: AppColor.grey300,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return InkWell(
      onTap: _openEmailApp,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.info.withOpacity(0.2),
              AppColor.secondaryPrimaryColor.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColor.info.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.info.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColor.info,
                          AppColor.info.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.info.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.headset_mic_rounded,
                      color: AppColor.white,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.bold(
                          'Need Help?',
                          fontSize: 15,
                          color: AppColor.white,
                        ),
                        SizedBox(height: 4.h),
                        AppText.small(
                          'Our support team is ready to assist',
                          color: AppColor.grey300,
                          fontSize: 11,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColor.info.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Icon(
                    Icons.email_rounded,
                    color: AppColor.lighterGreen,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.small(
                          'Email Support',
                          color: AppColor.grey500,
                          fontSize: 11,
                        ),
                        SizedBox(height: 2.h),
                        AppText.medium(
                          supportEmail,
                          color: AppColor.lighterGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColor.grey500,
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.warning.withOpacity(0.15),
            AppColor.orange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColor.warning.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.warning.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.warning.withOpacity(0.3),
                  AppColor.warning.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.shield_outlined,
              color: AppColor.warning,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bold(
                  'Security Notice',
                  fontSize: 14,
                  color: AppColor.warning,
                ),
                SizedBox(height: 8.h),
                AppText.small(
                  'Only send USDT on BSC (BEP-20) network. Using different tokens or networks may result in permanent loss of funds.',
                  color: AppColor.grey300,
                  fontSize: 12,
                  textHeight: 1.5,
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _showQRCodeDialog(BuildContext context, String address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColor.secondaryPrimaryColor,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: AppColor.primaryColor.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText.bold(
                  'Wallet QR Code',
                  fontSize: 18,
                  color: AppColor.white,
                ),
                SizedBox(height: 8.h),
                AppText.small(
                  'Scan to pay (BEP-20)',
                  color: AppColor.grey500,
                  fontSize: 12,
                ),
                SizedBox(height: 24.h),

                // Your Asset Image
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Image.asset(
                    'assets/images/wallate_address_qr.jpeg', // Replace with your image path
                    width: 200.w,
                    height: 200.w,
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(height: 24.h),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: AppText.medium(
                      'Close',
                      color: AppColor.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}