import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_button.dart';
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
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Calculate profit values based on ROI
  Map<String, double> _calculateProfitValues(
      double amount,
      String? roiString,
      int durationDays,
      ) {
    if (roiString == null || roiString.isEmpty) {
      return {
        'minProfit': 0.0,
        'maxProfit': 0.0,
        'avgProfit': 0.0,
      };
    }

    try {
      // Parse ROI range (e.g., "1-1.5" to min=1, max=1.5)
      final roiParts = roiString.split('-');
      final minRoi = double.tryParse(roiParts[0]) ?? 0.0;
      final maxRoi = double.tryParse(roiParts.last) ?? 0.0;
      final avgRoi = (minRoi + maxRoi) / 2;

      // Calculate daily profit
      final minDailyProfit = (amount * minRoi) / 100;
      final maxDailyProfit = (amount * maxRoi) / 100;
      final avgDailyProfit = (amount * avgRoi) / 100;

      print('💰 Profit Calculation:');
      print('   Amount: $amount');
      print('   ROI Range: $minRoi% - $maxRoi%');
      print('   Min Daily: $minDailyProfit');
      print('   Max Daily: $maxDailyProfit');
      print('   Avg Daily: $avgDailyProfit');

      return {
        'minProfit': minDailyProfit,
        'maxProfit': maxDailyProfit,
        'avgProfit': avgDailyProfit,
      };
    } catch (e) {
      print('❌ Error calculating profit: $e');
      return {
        'minProfit': 0.0,
        'maxProfit': 0.0,
        'avgProfit': 0.0,
      };
    }
  }

  void _handleCreateDeposit() {
    final depositProvider = Provider.of<DepositProvider>(context, listen: false);
    final planProvider = Provider.of<PlanProvider>(context, listen: false);

    // Validate plan is selected
    if (_selectedPlanData == null || planProvider.selectedPlanDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a plan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    final minAmount =
        double.tryParse(planProvider.selectedPlanDetails?.minAmount ?? '0') ??
            0;
    final maxAmount =
        double.tryParse(planProvider.selectedPlanDetails?.maxAmount ?? '0') ??
            0;

    // Validate amount
    if (amount == null || amount < minAmount || amount > maxAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Amount must be between $minAmount and $maxAmount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Calculate profit values
    final profitValues = _calculateProfitValues(
      amount,
      planProvider.selectedPlanDetails?.dailyRoi,
      planProvider.selectedPlanDetails?.durationDays ?? 0,
    );

    // Convert API plan data to tariff data format
    final tariffData = {
      'name': planProvider.selectedPlanDetails?.name,
      'days': planProvider.selectedPlanDetails?.durationDays ?? 0,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'dailyRoi': planProvider.selectedPlanDetails?.dailyRoi,
      'description': planProvider.selectedPlanDetails?.description,
      'minProfit': profitValues['minProfit'],
      'maxProfit': profitValues['maxProfit'],
      'avgProfit': profitValues['avgProfit'],
    };

    // Create deposit using DepositProvider
    depositProvider.createDeposit(
      currency: _selectedCurrency,
      amount: amount,
      tariff: _selectedTariff,
      tariffData: tariffData,
    );

    print('✅ Deposit Created:');
    print('   Currency: $_selectedCurrency');
    print('   Amount: $amount');
    print('   Plan: ${planProvider.selectedPlanDetails?.name}');
    print('   Duration: ${planProvider.selectedPlanDetails?.durationDays} days');
    print('   ROI: ${planProvider.selectedPlanDetails?.dailyRoi}%');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        onDone: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final depositProvider = Provider.of<DepositProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    final planProvider = Provider.of<PlanProvider>(context);

    // Get profit values from selected plan
    final profitValues = _selectedPlanData != null
        ? _calculateProfitValues(
      double.tryParse(_amountController.text) ?? 0,
      planProvider.selectedPlanDetails?.dailyRoi,
      planProvider.selectedPlanDetails?.durationDays ?? 0,
    )
        : {'minProfit': 0.0, 'maxProfit': 0.0, 'avgProfit': 0.0};

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: CustomAppBar(title: 'Create Deposit'),
      drawer: const CustomDrawer(currentRoute: 'home'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            BalanceCard(
              balance: homeProvider.balance,
              profitPercentage: homeProvider.profitPercentage,
            ),
            SizedBox(height: 20.h),

            // Choose Balance
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

            // Tariff Card with API (auto-selects first plan)
            TariffCardWithAPI(
              selectedTariff: _selectedTariff,
              onTariffChanged: (tariffId, planData) {
                setState(() {
                  _selectedTariff = tariffId;
                  _selectedPlanData = planData;
                });
              },
            ),
            SizedBox(height: 20.h),

            // Show amount card only if plan is selected
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

            // Show profit per day card
            if (_selectedPlanData != null &&
                planProvider.selectedPlanDetails != null &&
                _amountController.text.isNotEmpty)
              ProfitPerDayCard(tariffData: {
                'minProfit': profitValues['minProfit'],
                'maxProfit': profitValues['maxProfit'],
                'avgProfit': profitValues['avgProfit'],
              }),
            if (_selectedPlanData != null &&
                planProvider.selectedPlanDetails != null &&
                _amountController.text.isNotEmpty)
              SizedBox(height: 20.h),

            // Show profit by period card
            if (_selectedPlanData != null &&
                planProvider.selectedPlanDetails != null &&
                _amountController.text.isNotEmpty)
              ProfitByPeriodCard(
                amountController: _amountController,
                tariffData: {
                  'avgProfit': profitValues['avgProfit'],
                  'days': planProvider.selectedPlanDetails?.durationDays ?? 0,
                },
              ),
            if (_selectedPlanData != null &&
                planProvider.selectedPlanDetails != null &&
                _amountController.text.isNotEmpty)
              SizedBox(height: 20.h),

            // Show plan details card
            if (_selectedPlanData != null &&
                planProvider.selectedPlanDetails != null)
              PlanDetailsCard(tariffData: {
                'days': planProvider.selectedPlanDetails?.durationDays ?? 0,
              }),
            SizedBox(height: 30.h),

            // Create Deposit Button
            AppButton.primary(
              onPressed: _handleCreateDeposit,
              text: 'Create Deposit',
              width: double.infinity,
              height: 55,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}