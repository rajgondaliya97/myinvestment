import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_flush_bar.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../res/app_widget/custom_text_field.dart';
import '../../../utils/app_color.dart';
import '../../../view_model/wallet_controller.dart';
import '../../../view_model/auth_provider.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({Key? key}) : super(key: key);

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final TextEditingController _amountController = TextEditingController();
  final List<int> _quickAmounts = [100, 500, 1000, 5000, 10000];
  int? _selectedAmount;
  String? _amountError;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectQuickAmount(int amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toString();
      _amountError = null;
    });
  }

  bool _validateAmount() {
    final amount = _amountController.text.trim();

    if (amount.isEmpty) {
      setState(() {
        _amountError = 'Please enter an amount';
      });
      return false;
    }

    final numAmount = int.tryParse(amount);
    if (numAmount == null) {
      setState(() {
        _amountError = 'Please enter a valid amount';
      });
      return false;
    }

    if (numAmount <= 0) {
      setState(() {
        _amountError = 'Amount must be greater than 0';
      });
      return false;
    }

    if (numAmount > 1000000) {
      setState(() {
        _amountError = 'Maximum amount is \$1,000,000';
      });
      return false;
    }

    setState(() {
      _amountError = null;
    });
    return true;
  }

  void _addBalance() async {
    if (!_validateAmount()) {
      return;
    }

    final amount = int.parse(_amountController.text.trim());
    final walletController = context.read<WalletController>();
    final authController = context.read<AuthController>();

    final success = await walletController.addWalletBalance(balance: amount);

    if (success && mounted) {
      // Refresh user profile to get updated wallet balance
      await authController.fetchUserProfile();

      FlushbarHelper.showSuccess(
        context: context,
        message: 'Balance added successfully! New balance: \$${walletController.walletData?.balance}',
      );

      await Future.delayed(Duration(milliseconds: 800));
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else if (mounted) {
      final errorMessage = walletController.errorMessage ?? 'Failed to add balance';
      FlushbarHelper.showError(
        context: context,
        message: errorMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final currentBalance = authController.profileData?.walletBalance ?? '0';

    return Scaffold(
      backgroundColor: AppColor.secondaryPrimaryColor,
      appBar: CustomAppBar(title: 'Add Wallet Balance'),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColor.screenGradientBgColor,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Balance Card
              _buildCurrentBalanceCard(currentBalance.toString()),
              SizedBox(height: 30.h),

              // Amount Input Section
              AppText.medium(
                'Enter Amount',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              SizedBox(height: 12.h),

              // Amount Text Field
              CustomTextField(
                hint: 'Enter amount',
                icon: Icons.attach_money,
                controller: _amountController,
                errorText: _amountError,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAmount = null;
                    _amountError = null;
                  });
                },
              ),
              SizedBox(height: 24.h),

              // Quick Amount Selection
              AppText.medium(
                'Quick Select',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              SizedBox(height: 12.h),

              _buildQuickAmountGrid(),
              SizedBox(height: 30.h),

              // Information Card
              _buildInfoCard(),
              SizedBox(height: 30.h),

              // Add Balance Button
              Consumer<WalletController>(
                builder: (context, walletController, child) {
                  return AppButton.primary(
                    onPressed: walletController.isLoading ? null : _addBalance,
                    text: walletController.isLoading ? 'Processing...' : 'Add Balance',
                    width: double.infinity,
                    height: 55,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentBalanceCard(String balance) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.lighterGreen.withOpacity(0.8),
            AppColor.primaryColor.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              AppText.medium(
                'Current Wallet Balance',
                fontSize: 14,
                color: Colors.white70,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          AppText.large(
            '\$$balance',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountGrid() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: _quickAmounts.map((amount) {
        final isSelected = _selectedAmount == amount;
        return GestureDetector(
          onTap: () => _selectQuickAmount(amount),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                colors: [
                  AppColor.lighterGreen,
                  AppColor.primaryColor,
                ],
              )
                  : LinearGradient(
                colors: [
                  AppColor.secondaryPrimaryColor.withOpacity(0.8),
                  AppColor.primaryColor.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? AppColor.lighterGreen
                    : AppColor.lighterGreen.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: AppText.medium(
              '\$$amount',
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: Colors.white,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor.withOpacity(0.2),
            AppColor.secondaryPrimaryColor.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue[300],
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.medium(
                  'Important Information',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[300],
                ),
                SizedBox(height: 8.h),
                AppText.medium(
                  '• Minimum deposit: \$10\n'
                      '• Maximum deposit: \$1,000,000\n'
                      '• Balance will be added instantly\n'
                      '• You can use this balance for investments',
                  fontSize: 12,
                  color: Colors.grey[400],
                  //height: 1.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}