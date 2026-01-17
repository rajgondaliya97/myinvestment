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

class WithdrawAmountScreen extends StatefulWidget {
  const WithdrawAmountScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawAmountScreen> createState() => _WithdrawAmountScreenState();
}

class _WithdrawAmountScreenState extends State<WithdrawAmountScreen> {
  final TextEditingController _amountController = TextEditingController();
  final List<int> _quickAmounts = [100, 500, 1000, 5000];
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

  void _selectMaxAmount() {
    final walletController = context.read<WalletController>();
    final maxAmount = walletController.availableBalance;

    setState(() {
      _selectedAmount = null;
      _amountController.text = maxAmount.toString();
      _amountError = null;
    });
  }

  bool _validateAmount() {
    final amount = _amountController.text.trim();
    final walletController = context.read<WalletController>();
    final availableBalance = walletController.availableBalance;

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
        _amountError = 'Minimum withdrawal amount is \$10';
      });
      return false;
    }

    if (numAmount > availableBalance) {
      setState(() {
        _amountError = 'Insufficient balance. Available: \$${availableBalance}';
      });
      return false;
    }

    setState(() {
      _amountError = null;
    });
    return true;
  }

  void _withdrawBalance() async {
    if (!_validateAmount()) {
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.secondaryPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: AppColor.primaryColor.withOpacity(0.3)),
        ),
        title: AppText.large(
          'Confirm Withdrawal',
          fontWeight: FontWeight.w700,
        ),
        content: AppText.medium(
          'Are you sure you want to withdraw \$${_amountController.text}?',
          color: AppColor.grey500,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText.medium(
              'Cancel',
              color: AppColor.grey500,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: AppText.medium(
              'Withdraw',
              color: AppColor.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final amount = int.parse(_amountController.text.trim());
    final walletController = context.read<WalletController>();

    final success = await walletController.withdrawBalance(amount: amount);

    if (success && mounted) {
      FlushbarHelper.showSuccess(
        context: context,
        message: 'Withdrawal successful! Remaining balance: \$${walletController.availableBalance}',
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
      final errorMessage = walletController.errorMessage ?? 'Failed to withdraw balance';
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
      appBar: CustomAppBar(title: 'Withdraw Amount',showDrawer: false),
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
                    // Available Balance Card
                    _buildAvailableBalanceCard(walletController),
                    SizedBox(height: 30.h),

                    // Amount Input Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText.medium(
                          'Withdrawal Amount',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        GestureDetector(
                          onTap: _selectMaxAmount,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColor.lighterGreen.withOpacity(0.3),
                                  AppColor.primaryColor.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: AppColor.lighterGreen.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: AppText.medium(
                              'Withdraw Max',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColor.lighterGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Amount Text Field
                    CustomTextField(
                      hint: 'Enter withdrawal amount',
                      icon: Icons.money_off,
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
                    /*
                    SizedBox(height: 24.h),
                    // Quick Amount Selection
                    AppText.medium(
                      'Quick Select',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12.h),*/

                    //_buildQuickAmountGrid(walletController.availableBalance),
                    SizedBox(height: 24.h),

                    // Warning Card
                    _buildWarningCard(),
                    SizedBox(height: 24.h),

                    // Withdraw Button
                    AppButton.primary(
                      onPressed: walletController.isLoading ? null : _withdrawBalance,
                      text: walletController.isLoading ? 'Processing...' : 'Withdraw Amount',
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

  Widget _buildAvailableBalanceCard(WalletController walletController) {
    final availableBalance = walletController.availableBalance;
    final lockedBalance = walletController.lockedBalance;

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
            color: Colors.orange.withOpacity(0.3),
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
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  AppText.medium(
                    'Available to Withdraw',
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
            '\$$availableBalance',
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          if (lockedBalance > 0) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: Colors.white70,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  AppText.medium(
                    'Locked in investments: \$$lockedBalance',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickAmountGrid(int availableBalance) {
    // Filter quick amounts to only show amounts less than or equal to available balance
    final validAmounts = _quickAmounts.where((amount) => amount <= availableBalance).toList();

    if (validAmounts.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.secondaryPrimaryColor.withOpacity(0.8),
              AppColor.primaryColor.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.orange.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.orange[300],
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AppText.medium(
                'Insufficient balance for quick withdrawals',
                fontSize: 13,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: validAmounts.map((amount) {
        final isSelected = _selectedAmount == amount;
        return GestureDetector(
          onTap: () => _selectQuickAmount(amount),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: /*isSelected
                  ? LinearGradient(
                colors: [
                  Colors.orange,
                  Colors.deepOrange,
                ],
              )
                  : LinearGradient(
                colors: [
                  AppColor.secondaryPrimaryColor.withOpacity(0.8),
                  AppColor.primaryColor.withOpacity(0.2),
                ],
              )*/isSelected
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
                color: AppColor.lighterGreen.withOpacity(0.3),
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

  Widget _buildWarningCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.15),
            AppColor.secondaryPrimaryColor.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red[300],
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.medium(
                  'Important Notice',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[300],
                ),
                SizedBox(height: 8.h),
                AppText.medium(
                      '• Withdrawal charge: 10% of the amount\n'
                      '• You can only withdraw available balance\n'
                      '• Locked balance cannot be withdrawn\n'
                      '• Processing time: Instant\n'
                      '• Transaction cannot be reversed',
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
            color: Colors.orange,
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
              backgroundColor: Colors.orange,
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