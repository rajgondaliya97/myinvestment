import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/res/services/wallet_dashboard_screen.dart';
import 'package:myinvestment/res/services/web_wallet_service.dart';
import 'package:myinvestment/utils/app_color.dart';
import 'package:provider/provider.dart';

import '../../utils/app_constent.dart';
import '../app_widget/custom_app_bar.dart';
import '../app_widget/custom_app_text.dart';

class WalletImportScreen extends StatefulWidget {
  const WalletImportScreen({Key? key}) : super(key: key);

  @override
  State<WalletImportScreen> createState() => _WalletImportScreenState();
}

class _WalletImportScreenState extends State<WalletImportScreen>
    with SingleTickerProviderStateMixin {
  final _privateKeyController = TextEditingController();
  bool _isLoading = false;
  bool _obscureKey = true;
  bool _saveKey = true;
  String _errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _privateKeyController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _importWallet() async {
    if (_privateKeyController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your private key');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final walletService =
      Provider.of<Web3WalletService>(context, listen: false);

      await walletService.importWalletFromPrivateKey(
        _privateKeyController.text.trim(),
        saveKey: _saveKey,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const WalletDashboardScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      setState(() {
        _privateKeyController.text = clipboardData!.text!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppConst.appName,showBackButton: true,showDrawer: false,),
      body: Container(
        decoration: BoxDecoration(gradient: AppColor.screenGradientBgColor),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 20.h),
                        _buildHeaderSection(),
                        SizedBox(height: 32.h),
                        _buildPrivateKeyInput(),
                        if (_errorMessage.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          _buildErrorMessage(),
                        ],
                        SizedBox(height: 24.h),
                        _buildSaveKeyOption(),
                        SizedBox(height: 32.h),
                        _buildImportButton(),
                        SizedBox(height: 32.h),
                        _buildSecurityWarning(),
                        SizedBox(height: 24.h),
                        _buildHowToSection(),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: AppColor.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColor.primaryColor.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            size: 30.sp,
            color: AppColor.white,
          ),
        ),
        SizedBox(height: 24.h),
        AppText.medium(
           'Import Your Wallet',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColor.white,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        AppText.medium(
           'Securely import your wallet using your MetaMask private key',
      //    fontSize: 14.sp,
          color: AppColor.grey300.withOpacity(0.7),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildPrivateKeyInput() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: _errorMessage.isNotEmpty
              ? AppColor.error
              : AppColor.primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _errorMessage.isNotEmpty
                ? AppColor.error.withOpacity(0.2)
                : AppColor.primaryColor.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: AppColor.primaryGradient,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.key_rounded,
                    color: AppColor.white,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                AppText(
                   'Private Key',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.white,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColor.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColor.white.withOpacity(0.1),
                ),
              ),
              child: TextField(
                controller: _privateKeyController,
                maxLines: _obscureKey ? 1 : 3,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: 'monospace',
                  color: AppColor.white,
                  letterSpacing: 0.5,
                ),
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    color: AppColor.grey300.withOpacity(0.3),
                    fontFamily: 'monospace',
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIconButton(
                        icon: _obscureKey
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        onPressed: () {
                          setState(() => _obscureKey = !_obscureKey);
                        },
                        color: AppColor.grey300,
                      ),
                      SizedBox(width: 4.w),
                      _buildIconButton(
                        icon: Icons.content_paste_rounded,
                        onPressed: _pasteFromClipboard,
                        color: AppColor.info,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
      color: AppColor.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.all(8.w),
          child: Icon(
            icon,
            size: 20.sp,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.error.withOpacity(0.2),
            AppColor.error.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColor.error, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColor.error, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: AppText(
               _errorMessage,
              color: AppColor.error,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveKeyOption() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: AppColor.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _saveKey = !_saveKey);
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    gradient: _saveKey
                        ? AppColor.primaryGradient
                        : LinearGradient(
                      colors: [
                        AppColor.grey500.withOpacity(0.3),
                        AppColor.grey500.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: _saveKey
                          ? AppColor.primaryColor
                          : AppColor.grey500,
                      width: 2,
                    ),
                  ),
                  child: _saveKey
                      ? Icon(
                    Icons.check_rounded,
                    color: AppColor.white,
                    size: 16.sp,
                  )
                      : null,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                         'Remember this wallet',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.white,
                      ),
                      SizedBox(height: 4.h),
                      AppText(
                         'Private key will be encrypted and stored securely',
                        fontSize: 12.sp,
                        color: AppColor.grey300.withOpacity(0.6),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImportButton() {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        gradient: _isLoading ? null : AppColor.primaryGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          if (!_isLoading)
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Material(
        color: _isLoading
            ? AppColor.grey500.withOpacity(0.3)
            : AppColor.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: _isLoading ? null : _importWallet,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: _isLoading
                ? SizedBox(
              height: 24.h,
              width: 24.h,
              child: CircularProgressIndicator(
                color: AppColor.white,
                strokeWidth: 2.5,
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.import_export_rounded,
                  size: 22.sp,
                  color: AppColor.white,
                ),
                SizedBox(width: 12.w),
                AppText(
                   'Import Wallet',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityWarning() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.warning.withOpacity(0.15),
            AppColor.orange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColor.warning.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColor.warning, AppColor.orange],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: AppColor.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              AppText(
                 'Security Warning',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.warning,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildWarningItem('Never share your private key with anyone'),
          _buildWarningItem('We will never ask for your private key'),
          _buildWarningItem('Make sure you trust this app before importing'),
          _buildWarningItem('Keep your private key backed up safely'),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColor.success.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: AppColor.success,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: AppText(
               text,
              fontSize: 13.sp,
              color: AppColor.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColor.info.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColor.info, AppColor.info.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  color: AppColor.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppText(
                   'How to get your private key',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildHowToStep('1', 'Open MetaMask app or extension'),
          _buildHowToStep('2', 'Tap on the menu (three dots)'),
          _buildHowToStep('3', 'Select "Account Details"'),
          _buildHowToStep('4', 'Tap "Export Private Key"'),
          _buildHowToStep('5', 'Enter your MetaMask password'),
          _buildHowToStep('6', 'Copy the private key and paste here'),
        ],
      ),
    );
  }

  Widget _buildHowToStep(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              gradient: AppColor.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: AppText(
                 number,
                color: AppColor.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: AppText(
               text,
              color: AppColor.white.withOpacity(0.85),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
