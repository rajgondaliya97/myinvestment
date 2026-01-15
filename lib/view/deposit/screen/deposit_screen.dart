import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_flush_bar.dart';
import '../../../res/services/web_wallet_service.dart';
import '../../../utils/app_color.dart';
import '../../../view_model/deposit_provider.dart';
import '../../../view_model/home_provider.dart';
import '../../../view_model/pan_provider.dart';
import '../../../model/plan_model/get_plan_model.dart';
import '../../home/widget/balance_card_widget.dart';
import '../../home/widget/custom_drawer.dart';
import '../widget/choose_balance_card.dart';
import '../widget/deposit_amount_card.dart';
import '../widget/plan_details_card.dart';
import '../widget/profit_by_period_card.dart';
import '../widget/profit_per_day_card.dart';
import '../widget/success_dialog.dart';
import '../widget/tariff_card_with_api.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({Key? key}) : super(key: key);

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedCurrency = 'USD';
  String _selectedTariff = '';
  GetPlanModelData? _selectedPlanData;

  // Client wallet address where deposits will be sent
  // TODO: Replace with your actual client wallet address
  static const String CLIENT_WALLET_ADDRESS = '0x8d0fac10c3aae4e34a4e83bde920e0a9eda70bfd';

  @override
  void initState() {
    super.initState();
    _setupSubscriptionListener();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Setup listener for subscription state changes
  void _setupSubscriptionListener() {
    Future.delayed(Duration.zero, () {
      final depositProvider =
      Provider.of<DepositProvider>(context, listen: false);

      if (depositProvider.hasSubscriptionSuccess) {
        // Show success flushbar
        FlushbarHelper.showSuccess(
          context: context,
          title: 'Subscription Successful! 🎉',
          message: depositProvider.subscriptionSuccess ?? 'Plan subscribed',
          duration: Duration(seconds: 4),
        );

        // Show success dialog after flushbar
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => SuccessDialog(
                onDone: () {
                  Navigator.of(dialogContext).pop();
                  Future.delayed(Duration(milliseconds: 300), () {
                    if (mounted) {
                      Navigator.of(context).pop();
                      depositProvider.clearSubscriptionMessages();
                    }
                  });
                },
              ),
            );
          }
        });
      } else if (depositProvider.hasSubscriptionError) {
        // Show error flushbar
        FlushbarHelper.showError(
          context: context,
          title: 'Subscription Failed',
          message: depositProvider.subscriptionError ?? 'Something went wrong',
          duration: Duration(seconds: 4),
        );

        // Clear error after showing
        Future.delayed(Duration(seconds: 4), () {
          if (mounted) {
            depositProvider.clearSubscriptionMessages();
          }
        });
      }
    });
  }

  /// ============ VALIDATION BEFORE SUBSCRIBE ============
  Future<bool> _validateBeforeSubscribe(
      DepositProvider depositProvider,
      PlanProvider planProvider,
      Web3WalletService walletService,
      ) async {
    // 1. Check if plan is selected
    if (_selectedPlanData == null || planProvider.selectedPlanDetails == null) {
      FlushbarHelper.showError(
        context: context,
        title: 'No Plan Selected',
        message: 'Please select a plan first',
        duration: Duration(seconds: 3),
      );
      return false;
    }

    // 2. Check if amount is entered
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      FlushbarHelper.showError(
        context: context,
        title: 'Amount Required',
        message: 'Please enter deposit amount',
        duration: Duration(seconds: 3),
      );
      return false;
    }

    // 3. Parse amount
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      FlushbarHelper.showError(
        context: context,
        title: 'Invalid Amount',
        message: 'Please enter a valid amount greater than 0',
        duration: Duration(seconds: 3),
      );
      return false;
    }

    // 4. Check min and max amount
    final minAmount =
        double.tryParse(planProvider.selectedPlanDetails?.minAmount ?? '0') ??
            0;
    final maxAmount =
        double.tryParse(planProvider.selectedPlanDetails?.maxAmount ?? '0') ??
            0;

    if (amount < minAmount) {
      FlushbarHelper.showError(
        context: context,
        title: 'Amount Too Low',
        message: 'Minimum deposit amount is \$${minAmount.toStringAsFixed(2)}',
        duration: Duration(seconds: 3),
      );
      return false;
    }

    if (amount > maxAmount) {
      FlushbarHelper.showError(
        context: context,
        title: 'Amount Too High',
        message: 'Maximum deposit amount is \$${maxAmount.toStringAsFixed(2)}',
        duration: Duration(seconds: 3),
      );
      return false;
    }

    // 5. Check wallet balance from Web3WalletService
    if (walletService.isConnected) {
      try {
        // Get USDT balance from wallet
        final usdtBalance = await walletService.getUsdtBalance();
        final currentBalance = double.tryParse(usdtBalance) ?? 0.0;

        if (currentBalance < amount) {
          FlushbarHelper.showWarning(
            context: context,
            title: 'Insufficient Balance',
            message:
            'Your wallet balance (\$${currentBalance.toStringAsFixed(2)} USDT) is less than the deposit amount (\$${amount.toStringAsFixed(2)})',
            duration: Duration(seconds: 5),
          );
          return false;
        }

        debugPrint('✅ Balance check passed: \$${currentBalance.toStringAsFixed(2)} USDT available');
      } catch (e) {
        debugPrint('⚠️ Balance check error: $e');
        FlushbarHelper.showWarning(
          context: context,
          title: 'Balance Check Failed',
          message: 'Could not verify wallet balance. Error: ${e.toString()}',
          duration: Duration(seconds: 4),
        );
        return false;
      }
    } else {
      // Wallet not connected
      FlushbarHelper.showError(
        context: context,
        title: 'Wallet Not Connected',
        message: 'Please connect your wallet to proceed with the deposit',
        duration: Duration(seconds: 4),
      );
      return false;
    }

    // All validations passed
    return true;
  }

  /// ============ TRANSFER USDT TO CLIENT ACCOUNT ============
  Future<bool> _transferUsdtToClient(
      Web3WalletService walletService,
      double amount,
      ) async {
    try {
      debugPrint('💸 [Deposit] Starting USDT transfer...');
      debugPrint('💸 [Deposit] Amount: \$${amount.toStringAsFixed(2)} USDT');
      debugPrint('💸 [Deposit] To: $CLIENT_WALLET_ADDRESS');
      debugPrint('💸 [Deposit] Network: ${walletService.currentNetwork}');

      // Show transfer loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Colors.grey[900],
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColor.primaryColor),
                SizedBox(height: 16.h),
                Text(
                  'Processing Transfer...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Sending \$${amount.toStringAsFixed(2)} USDT',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please wait, do not close the app',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );

      // Send USDT to client wallet
      final txHash = await walletService.sendUsdt(
        toAddress: CLIENT_WALLET_ADDRESS,
        amount: amount.toStringAsFixed(2),
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      debugPrint('✅ [Deposit] Transfer successful!');
      debugPrint('✅ [Deposit] Transaction Hash: $txHash');

      // Show success message
      FlushbarHelper.showSuccess(
        context: context,
        title: 'Transfer Successful! 💰',
        message: 'USDT transferred successfully. Transaction: ${txHash.substring(0, 10)}...',
        duration: Duration(seconds: 5),
      );

      // Store transaction hash for reference
      // You can save this to your backend or local storage
      await _saveTransactionRecord(
        txHash: txHash,
        amount: amount,
        network: walletService.currentNetwork ?? 'unknown',
      );

      return true;
    } catch (e) {
      debugPrint('❌ [Deposit] Transfer error: $e');

      // Close loading dialog if still open
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error message
      FlushbarHelper.showError(
        context: context,
        title: 'Transfer Failed',
        message: 'Failed to transfer USDT: ${e.toString()}',
        duration: Duration(seconds: 5),
      );

      return false;
    }
  }

  /// ============ SAVE TRANSACTION RECORD ============
  Future<void> _saveTransactionRecord({
    required String txHash,
    required double amount,
    required String network,
  }) async {
    try {
      // TODO: Save transaction to your backend
      // Example: Call your API to record the transaction
      debugPrint('💾 [Deposit] Saving transaction record...');
      debugPrint('💾 [Deposit] TxHash: $txHash');
      debugPrint('💾 [Deposit] Amount: \$${amount.toStringAsFixed(2)}');
      debugPrint('💾 [Deposit] Network: $network');

      // You can add API call here to save transaction details
      // await depositProvider.saveTransactionRecord(
      //   txHash: txHash,
      //   amount: amount,
      //   network: network,
      // );

    } catch (e) {
      debugPrint('⚠️ [Deposit] Failed to save transaction record: $e');
      // Don't throw error - transaction was successful even if record save fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<DepositProvider, HomeProvider, PlanProvider, Web3WalletService>(
      builder: (context, depositProvider, homeProvider, planProvider, walletService, child) {
        // Get profit values from deposit provider
        final amount = double.tryParse(_amountController.text) ?? 0;
        final profitValues =
        depositProvider.calculateProfitDetails(amount: amount);

        return Scaffold(
          backgroundColor: AppColor.secondaryPrimaryColor,
          appBar: CustomAppBar(title: 'Create Deposit'),
          drawer: const CustomDrawer(currentRoute: 'deposit'),
          body: Container(
            decoration: BoxDecoration(
              gradient: AppColor.screenGradientBgColor,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============ BALANCE CARD ============
                  BalanceCard(),
                  SizedBox(height: 20.h),

                  // ============ TARIFF CARD (Auto-selects first plan) ============
                  TariffCardWithAPI(
                    selectedTariff: _selectedTariff,
                    onTariffChanged: (tariffId, planData) {
                      setState(() {
                        _selectedTariff = tariffId;
                        _selectedPlanData = planData;
                        _amountController.clear();
                        depositProvider.clearSubscriptionMessages();
                      });
                    },
                  ),
                  SizedBox(height: 20.h),

                  // ============ AMOUNT CARD (Shown if plan selected) ============
                  if (_selectedPlanData != null &&
                      planProvider.selectedPlanDetails != null)
                    DepositAmountCard(
                      controller: _amountController,
                      tariffData: {
                        'minAmount':
                        planProvider.selectedPlanDetails?.minAmount ?? '0',
                        'maxAmount':
                        planProvider.selectedPlanDetails?.maxAmount ?? '0',
                      },
                    ),
                  if (_selectedPlanData != null &&
                      planProvider.selectedPlanDetails != null)
                    SizedBox(height: 20.h),

                  // ============ VALIDATION MESSAGE (if amount is invalid) ============
                  if (_selectedPlanData != null &&
                      planProvider.selectedPlanDetails != null &&
                      _amountController.text.isNotEmpty)
                    _buildValidationMessage(planProvider, walletService),

                  if (_selectedPlanData != null &&
                      planProvider.selectedPlanDetails != null &&
                      _amountController.text.isNotEmpty)
                    SizedBox(height: 20.h),

                  // ============ PLAN DETAILS CARD ============
                  if (_selectedPlanData != null &&
                      planProvider.selectedPlanDetails != null)
                    PlanDetailsCard(tariffData: {
                      'days':
                      planProvider.selectedPlanDetails?.durationDays ?? 0,
                    }),
                  SizedBox(height: 30.h),

                  // ============ SUBSCRIBE BUTTON ============
                  AppButton.primary(
                    onPressed: depositProvider.isSubscribing || !walletService.isConnected
                        ? null
                        : () => _handleSubscribeClick(
                        depositProvider, planProvider, walletService),
                    text: depositProvider.isSubscribing
                        ? 'Processing...'
                        : !walletService.isConnected
                        ? 'Connect Wallet First'
                        : 'Deposit & Subscribe Plan',
                    width: double.infinity,
                    height: 55,
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ============ WALLET STATUS CARD ============
  Widget _buildWalletStatusCard(Web3WalletService walletService) {
    if (!walletService.isConnected) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.warning.withOpacity(0.2),
              AppColor.warning.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColor.warning, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                color: AppColor.warning, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet Not Connected',
                    style: TextStyle(
                      color: AppColor.warning,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Please connect your wallet to make deposits',
                    style: TextStyle(
                      color: AppColor.warning.withOpacity(0.8),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/import');
              },
              icon: Icon(Icons.arrow_forward, color: AppColor.warning),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.success.withOpacity(0.2),
            AppColor.success.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.success, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,
              color: AppColor.success, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet Connected',
                  style: TextStyle(
                    color: AppColor.success,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${walletService.address?.substring(0, 6)}...${walletService.address?.substring(38)} • ${walletService.currentNetwork?.toUpperCase()}',
                  style: TextStyle(
                    color: AppColor.success.withOpacity(0.8),
                    fontSize: 11.sp,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColor.success,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'READY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ============ VALIDATION MESSAGE WIDGET ============
  Widget _buildValidationMessage(PlanProvider planProvider, Web3WalletService walletService) {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return SizedBox.shrink();

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      return _buildErrorMessage('Please enter a valid amount');
    }

    final minAmount =
        double.tryParse(planProvider.selectedPlanDetails?.minAmount ?? '0') ??
            0;
    final maxAmount =
        double.tryParse(planProvider.selectedPlanDetails?.maxAmount ?? '0') ??
            0;

    if (amount < minAmount) {
      return _buildErrorMessage(
          'Amount must be at least \$${minAmount.toStringAsFixed(2)}');
    }

    if (amount > maxAmount) {
      return _buildErrorMessage(
          'Amount cannot exceed \$${maxAmount.toStringAsFixed(2)}');
    }

    // Valid amount
    return _buildSuccessMessage(
        'Amount is valid! Click below to deposit and subscribe.');
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.error.withOpacity(0.2),
            AppColor.error.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.error, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColor.error, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColor.error,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(String message) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.success.withOpacity(0.2),
            AppColor.success.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.success, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,
              color: AppColor.success, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColor.success,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ============ SUBSCRIBE CLICK HANDLER WITH VALIDATION & TRANSFER ============
  void _handleSubscribeClick(
      DepositProvider depositProvider,
      PlanProvider planProvider,
      Web3WalletService walletService,
      ) async {
    // Step 1: Run all validations (including balance check)
    final isValid = await _validateBeforeSubscribe(
      depositProvider,
      planProvider,
      walletService,
    );

    if (!isValid) {
      return; // Stop if validation fails
    }

    // Parse amount (we know it's valid from validation)
    final amount = double.parse(_amountController.text.trim());

    // Step 2: Transfer USDT to client account
    final transferSuccess = await _transferUsdtToClient(
      walletService,
      amount,
    );

    if (!transferSuccess) {
      FlushbarHelper.showError(
        context: context,
        title: 'Deposit Failed',
        message: 'USDT transfer failed. Please try again.',
        duration: Duration(seconds: 4),
      );
      return; // Stop if transfer fails
    }

    // Step 3: After successful transfer, subscribe to plan
    depositProvider
        .subscribePlan(
      selectedPlanData: _selectedPlanData!,
      amount: amount,
      dailyRoi: planProvider.selectedPlanDetails?.dailyRoi,
      durationDays: planProvider.selectedPlanDetails?.durationDays,
      minAmount: planProvider.selectedPlanDetails?.minAmount,
      maxAmount: planProvider.selectedPlanDetails?.maxAmount,
      description: planProvider.selectedPlanDetails?.description,
    )
        .then((_) {
      // Success handling is done in _setupSubscriptionListener
      debugPrint('✅ [Deposit] Plan subscription initiated');
    }).catchError((error) {
      FlushbarHelper.showError(
        context: context,
        title: 'Subscription Error',
        message: 'USDT transferred but plan subscription failed. Please contact support.',
        duration: Duration(seconds: 5),
      );
    });
  }
}