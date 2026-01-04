import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_flush_bar.dart';
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
                  // ✅ Close dialog using dialogContext
                  Navigator.of(dialogContext).pop();

                  // ✅ Pop screen using original context after a brief delay
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

  @override
  Widget build(BuildContext context) {
    return Consumer3<DepositProvider, HomeProvider, PlanProvider>(
      builder: (context, depositProvider, homeProvider, planProvider, child) {
        // Get profit values from deposit provider
        final amount = double.tryParse(_amountController.text) ?? 0;
        final profitValues =
        depositProvider.calculateProfitDetails(amount: amount);

        return Scaffold(
          backgroundColor: AppColor.secondaryPrimaryColor,
          appBar: CustomAppBar(title: 'Create Deposit'),
          drawer: const CustomDrawer(currentRoute: 'home'),
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
                  BalanceCard(
                    balance: homeProvider.balance,
                    profitPercentage: homeProvider.profitPercentage,
                  ),
                  SizedBox(height: 20.h),

                  // ============ CHOOSE BALANCE ============
                  ChooseBalanceCard(
                    selectedCurrency: _selectedCurrency,
                    onCurrencyChanged: (currency) {
                      setState(() => _selectedCurrency = currency);
                    },
                    usdBalance: depositProvider.usdBalance,
                    btcBalance: depositProvider.btcBalance,
                    ethBalance: depositProvider.ethBalance,
                  ),
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

                  // ============ PROFIT PER DAY CARD ============
                  if (_selectedPlanData != null &&
                      planProvider.selectedPlanDetails != null &&
                      _amountController.text.isNotEmpty)
                    ProfitPerDayCard(tariffData: {
                      'minProfit':
                      profitValues['minDailyProfit']?.toStringAsFixed(2) ??
                          '0',
                      'maxProfit':
                      profitValues['maxDailyProfit']?.toStringAsFixed(2) ??
                          '0',
                      'avgProfit':
                      profitValues['avgDailyProfit']?.toStringAsFixed(2) ??
                          '0',
                    }),
                  if (_selectedPlanData != null &&
                      planProvider.selectedPlanDetails != null &&
                      _amountController.text.isNotEmpty)
                    SizedBox(height: 20.h),

                  // ============ PROFIT BY PERIOD CARD ============
                  if (_selectedPlanData != null &&
                      planProvider.selectedPlanDetails != null &&
                      _amountController.text.isNotEmpty)
                    ProfitByPeriodCard(
                      amountController: _amountController,
                      tariffData: {
                        'avgProfit': double.tryParse(
                            profitValues['avgDailyProfit'].toString()) ??
                            0.0,
                        'days':
                        planProvider.selectedPlanDetails?.durationDays ?? 0,
                        'avgTotalProfit': profitValues['avgTotalProfit'] ?? 0.0,
                      },
                    ),
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
                    onPressed: depositProvider.isSubscribing
                        ? null
                        : () => _handleSubscribeClick(depositProvider, planProvider),
                    text: depositProvider.isSubscribing
                        ? 'Subscribing...'
                        : 'Subscribe Plan',
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

  /// ============ SIMPLE CLICK HANDLER ============
  /// Only calls provider method - NO LOGIC HERE
  void _handleSubscribeClick(
      DepositProvider depositProvider,
      PlanProvider planProvider,
      ) {
    // Show loading flushbar
    final loadingFlushbar = FlushbarHelper.showLoading(
      context: context,
      message:
      'Subscribing to ${_selectedPlanData?.name ?? "plan"}...',
      title: 'Processing',
    );

    // Call provider method with all data
    depositProvider.subscribePlan(
      selectedPlanData: _selectedPlanData!,
      amount: double.tryParse(_amountController.text) ?? 0,
      dailyRoi: planProvider.selectedPlanDetails?.dailyRoi,
      durationDays: planProvider.selectedPlanDetails?.durationDays,
      minAmount: planProvider.selectedPlanDetails?.minAmount,
      maxAmount: planProvider.selectedPlanDetails?.maxAmount,
      description: planProvider.selectedPlanDetails?.description,
    ).then((_) {
      // Dismiss loading flushbar
      loadingFlushbar.dismiss();
    });
  }
}