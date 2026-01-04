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
  void initState() {
    super.initState();
    // Fetch wallet balance when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletController>().fetchWalletBalance();
    });
  }

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

    if (numAmount < 10) {
      setState(() {
        _amountError = 'Minimum amount is \$10';
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

    final success = await walletController.addWalletBalance(balance: amount);

    if (success && mounted) {
      FlushbarHelper.showSuccess(
        context: context,
        message: 'Balance added successfully! New balance: \$${walletController.currentBalance}',
      );

      // Clear the input
      _amountController.clear();
      setState(() {
        _selectedAmount = null;
      });

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

  Future<void> _refreshBalance() async {
    await context.read<WalletController>().fetchWalletBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondaryPrimaryColor,
      appBar: CustomAppBar(title: 'Add Wallet Balance',showDrawer: false),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColor.screenGradientBgColor,
        ),
        child: Consumer<WalletController>(
          builder: (context, walletController, child) {
            if (walletController.isFetchingBalance && walletController.balanceData == null) {
              return _buildLoadingState();
            }

            if (walletController.errorMessage != null && walletController.balanceData == null) {
              return _buildErrorState(walletController.errorMessage!);
            }

            return RefreshIndicator(
              onRefresh: _refreshBalance,
              color: AppColor.lighterGreen,
              backgroundColor: AppColor.secondaryPrimaryColor,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Balance Card
                    _buildCurrentBalanceCard(walletController),
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
                    AppButton.primary(
                      onPressed: walletController.isLoading ? null : _addBalance,
                      text: walletController.isLoading ? 'Processing...' : 'Add Balance',
                      width: double.infinity,
                      height: 55,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentBalanceCard(WalletController walletController) {
    final currentBalance = walletController.currentBalance;
    final lockedBalance = walletController.lockedBalance;
    final availableBalance = walletController.availableBalance;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    'Wallet Balance',
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ],
              ),
              if (walletController.isFetchingBalance)
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          AppText.large(
            '\$$currentBalance',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          SizedBox(height: 16.h),
          // Balance Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceDetail('Available', availableBalance),
              Container(
                width: 1,
                height: 30.h,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildBalanceDetail('Locked', lockedBalance),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetail(String label, int amount) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText.medium(
            label,
            fontSize: 12,
            color: Colors.white60,
          ),
          SizedBox(height: 4.h),
          AppText.medium(
            '\$$amount',
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
                      '• You can use available balance for investments',
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColor.lighterGreen,
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          AppText.medium(
            'Loading wallet balance...',
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80.sp,
            color: Colors.red[400],
          ),
          SizedBox(height: 16.h),
          AppText.medium(
            'Oops! Something went wrong',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: AppText.medium(
              error,
              fontSize: 13,
              color: Colors.grey[500],
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _refreshBalance,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.lighterGreen,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: AppText.medium(
              'Retry',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}