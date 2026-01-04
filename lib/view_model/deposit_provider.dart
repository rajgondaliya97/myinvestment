import 'package:flutter/foundation.dart';
import '../api_services/api_exception.dart';
import '../model/plan_model/get_plan_model.dart';
import '../repo/plan_repo.dart';

class DepositProvider extends ChangeNotifier {
  final PlanRepository planRepository;

  // Balance Properties
  double _usdBalance = 26.75;
  double _btcBalance = 0.0;
  double _ethBalance = 0.0;

  // Deposit Properties
  List<Map<String, dynamic>> _deposits = [];

  // Subscription Properties
  bool _isSubscribing = false;
  String? _subscriptionError;
  String? _subscriptionSuccess;

  // Getters - Balance
  double get usdBalance => _usdBalance;
  double get btcBalance => _btcBalance;
  double get ethBalance => _ethBalance;

  double get totalBalance =>
      _usdBalance + (_btcBalance * 50000) + (_ethBalance * 3000);

  // Getters - Deposits
  List<Map<String, dynamic>> get deposits => _deposits;

  // Getters - Subscription
  bool get isSubscribing => _isSubscribing;
  String? get subscriptionError => _subscriptionError;
  String? get subscriptionSuccess => _subscriptionSuccess;
  bool get hasSubscriptionError => _subscriptionError != null;
  bool get hasSubscriptionSuccess => _subscriptionSuccess != null;

  // Active deposits count
  int get activeDepositsCount {
    return _deposits.where((d) => d['status'] == 'active').length;
  }

  // Total invested amount
  double get totalInvested {
    return _deposits
        .where((d) => d['status'] == 'active')
        .fold(0.0, (sum, d) => sum + (d['amount'] as double));
  }

  // Total profit earned
  double get totalProfitEarned {
    return _deposits.fold(0.0, (sum, d) => sum + ((d['totalProfit'] ?? 0.0) as double));
  }

  DepositProvider({required this.planRepository});

  /// ============ PRIVATE PROFIT CALCULATION ============
  /// Internal method for profit calculations
  Map<String, dynamic> _calculateProfitDetails(
      double investmentAmount,
      String? roiString,
      int durationDays,
      ) {
    if (roiString == null ||
        roiString.isEmpty ||
        investmentAmount <= 0 ||
        durationDays <= 0) {
      return {
        'minDailyProfit': 0.0,
        'maxDailyProfit': 0.0,
        'avgDailyProfit': 0.0,
        'minWeeklyProfit': 0.0,
        'maxWeeklyProfit': 0.0,
        'avgWeeklyProfit': 0.0,
        'minTotalProfit': 0.0,
        'maxTotalProfit': 0.0,
        'avgTotalProfit': 0.0,
      };
    }

    try {
      // Parse ROI range
      final roiParts = roiString.split('-');
      if (roiParts.length < 2) {
        throw Exception('Invalid ROI format');
      }

      final minRoiPercent = double.tryParse(roiParts[0].trim()) ?? 0.0;
      final maxRoiPercent = double.tryParse(roiParts[1].trim()) ?? 0.0;
      final avgRoiPercent = (minRoiPercent + maxRoiPercent) / 2;

      // Calculate daily profit
      final minDailyProfit = (investmentAmount * minRoiPercent) / 100;
      final maxDailyProfit = (investmentAmount * maxRoiPercent) / 100;
      final avgDailyProfit = (investmentAmount * avgRoiPercent) / 100;

      // Calculate weekly profit
      final minWeeklyProfit = minDailyProfit * 7;
      final maxWeeklyProfit = maxDailyProfit * 7;
      final avgWeeklyProfit = avgDailyProfit * 7;

      // Calculate total profit
      final minTotalProfit = minDailyProfit * durationDays;
      final maxTotalProfit = maxDailyProfit * durationDays;
      final avgTotalProfit = avgDailyProfit * durationDays;

      // Calculate total return
      final minTotalReturn = investmentAmount + minTotalProfit;
      final maxTotalReturn = investmentAmount + maxTotalProfit;
      final avgTotalReturn = investmentAmount + avgTotalProfit;

      return {
        'minDailyProfit': minDailyProfit,
        'maxDailyProfit': maxDailyProfit,
        'avgDailyProfit': avgDailyProfit,
        'minWeeklyProfit': minWeeklyProfit,
        'maxWeeklyProfit': maxWeeklyProfit,
        'avgWeeklyProfit': avgWeeklyProfit,
        'minTotalProfit': minTotalProfit,
        'maxTotalProfit': maxTotalProfit,
        'avgTotalProfit': avgTotalProfit,
        'minTotalReturn': minTotalReturn,
        'maxTotalReturn': maxTotalReturn,
        'avgTotalReturn': avgTotalReturn,
      };
    } catch (e) {
      print('❌ Error calculating profit: $e');
      return {
        'minDailyProfit': 0.0,
        'maxDailyProfit': 0.0,
        'avgDailyProfit': 0.0,
        'error': e.toString(),
      };
    }
  }

  /// ============ PUBLIC PROFIT CALCULATION ============
  /// Called from UI to get profit values for display
  /// Usage: depositProvider.calculateProfitDetails(amount: 1000)
  Map<String, dynamic> calculateProfitDetails({
    double amount = 0.0,
    String? roiString,
    int durationDays = 0,
  }) {
    return _calculateProfitDetails(amount, roiString, durationDays);
  }

  /// ============ VALIDATION LOGIC ============
  /// Validate plan selection, amount, and range
  String? _validateSubscription({
    required GetPlanModelData? selectedPlanData,
    required String? minAmount,
    required String? maxAmount,
    required double? amount,
  }) {
    // Check plan selected
    if (selectedPlanData == null) {
      return 'Please select a plan';
    }

    // Check amount input
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }

    // Check amount range
    final min = double.tryParse(minAmount ?? '0') ?? 0;
    final max = double.tryParse(maxAmount ?? '0') ?? 0;

    if (amount < min || amount > max) {
      return 'Amount must be between \$$min and \$$max';
    }

    return null; // Valid
  }

  /// ============ SUBSCRIBE PLAN LOGIC ============
  /// Main subscription method - calls API and manages state
  Future<void> subscribePlan({
    required GetPlanModelData selectedPlanData,
    required double amount,
    required String? dailyRoi,
    required int? durationDays,
    required String? minAmount,
    required String? maxAmount,
    required String? description,
  }) async {
    // Reset messages
    _subscriptionError = null;
    _subscriptionSuccess = null;
    _isSubscribing = true;
    notifyListeners();

    try {
      // Validate input
      final validationError = _validateSubscription(
        selectedPlanData: selectedPlanData,
        minAmount: minAmount,
        maxAmount: maxAmount,
        amount: amount,
      );

      if (validationError != null) {
        _subscriptionError = validationError;
        _isSubscribing = false;
        notifyListeners();
        return;
      }

      // Log subscription attempt
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🔄 SUBSCRIBING TO PLAN');
      print('═══════════════════════════════════════════════════════════');
      print('Plan Name: ${selectedPlanData.name}');
      print('Plan ID: ${selectedPlanData.id}');
      print('Amount: \$$amount');
      print('Duration: $durationDays days');
      print('ROI: $dailyRoi%');
      print('');

      // Call API
      print('📤 CALLING SUBSCRIBE PLAN API');
      print('Plan ID: ${selectedPlanData.id}');
      print('Amount: \$$amount');
      print('');

      final subscribeResponse = await planRepository.planSubscribe(
        plan_id: (selectedPlanData.id ?? 0).toString(),
        amount: amount,
      );

      print('📥 SUBSCRIBE PLAN RESPONSE');
      print('Status: ${subscribeResponse.status}');
      print('Message: ${subscribeResponse.message}');
      print('═══════════════════════════════════════════════════════════');
      print('');

      // Check response status
      if (subscribeResponse.status == 0) {
        // Success - calculate profits
        final profitValues = _calculateProfitDetails(
          amount,
          dailyRoi,
          durationDays ?? 0,
        );

        // Create local deposit record
        _createDeposit(
          currency: 'USD',
          amount: amount,
          planId: (selectedPlanData.id ?? 0).toString(),
          planName: selectedPlanData.name,
          planData: {
            'name': selectedPlanData.name,
            'days': durationDays ?? 0,
            'minAmount': double.tryParse(minAmount ?? '0') ?? 0,
            'maxAmount': double.tryParse(maxAmount ?? '0') ?? 0,
            'dailyRoi': dailyRoi,
            'description': description,
            'minProfit': profitValues['minDailyProfit'],
            'maxProfit': profitValues['maxDailyProfit'],
            'avgProfit': profitValues['avgDailyProfit'],
            'minWeeklyProfit': profitValues['minWeeklyProfit'],
            'maxWeeklyProfit': profitValues['maxWeeklyProfit'],
            'avgWeeklyProfit': profitValues['avgWeeklyProfit'],
            'minTotalProfit': profitValues['minTotalProfit'],
            'maxTotalProfit': profitValues['maxTotalProfit'],
            'avgTotalProfit': profitValues['avgTotalProfit'],
            'minTotalReturn': profitValues['minTotalReturn'],
            'maxTotalReturn': profitValues['maxTotalReturn'],
            'avgTotalReturn': profitValues['avgTotalReturn'],
          },
        );

        // Set success message
        _subscriptionSuccess =
        'Successfully subscribed to ${selectedPlanData.name} plan';

        print('✅ SUBSCRIPTION SUCCESSFUL');
        print('═══════════════════════════════════════════════════════════');
        print('');
        print('💾 Deposit record created locally');
        print('   Amount: \$$amount');
        print('   Plan: ${selectedPlanData.name}');
        print('   Daily Profit (Avg): \$${profitValues['avgDailyProfit']}');
        print('   Total Profit: \$${profitValues['avgTotalProfit']}');
      } else {
        // Error from API
        _subscriptionError =
            subscribeResponse.message ?? 'Subscription failed. Try again.';

        print('❌ SUBSCRIPTION FAILED');
        print('Status: ${subscribeResponse.status}');
        print('Message: ${subscribeResponse.message}');
        print('═══════════════════════════════════════════════════════════');
        print('');
      }
    } on ApiException catch (e) {
      _subscriptionError = e.message;
      print('❌ API EXCEPTION');
      print('Error: ${e.message}');
      print('Status Code: ${e.statusCode}');
      print('═══════════════════════════════════════════════════════════');
      print('');
    } catch (e) {
      _subscriptionError = 'An unexpected error occurred';
      print('❌ UNEXPECTED ERROR');
      print('Error: $e');
      print('═══════════════════════════════════════════════════════════');
      print('');
    } finally {
      _isSubscribing = false;
      notifyListeners();
    }
  }

  /// ============ LOCAL DEPOSIT MANAGEMENT ============
  /// Create local deposit record
  void _createDeposit({
    required String currency,
    required double amount,
    required String planId,
    required String? planName,
    required Map<String, dynamic> planData,
  }) {
    final now = DateTime.now();
    final expiryDate = now.add(Duration(days: planData['days']));

    final deposit = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'currency': currency,
      'amount': amount,
      'planId': planId,
      'planName': planName,
      'tariffData': planData,
      'openDate': now,
      'expiryDate': expiryDate,
      'status': 'active',
      'dailyProfit': 0.0,
      'totalProfit': 0.0,
    };

    _deposits.add(deposit);
    notifyListeners();
  }

  /// Create new deposit (legacy method)
  void createDeposit({
    required String currency,
    required double amount,
    required String tariff,
    required Map<String, dynamic> tariffData,
  }) {
    _createDeposit(
      currency: currency,
      amount: amount,
      planId: tariff,
      planName: tariffData['name'],
      planData: tariffData,
    );
  }

  /// Update balance
  void updateBalance(String currency, double amount) {
    if (currency == 'USD') {
      _usdBalance += amount;
    } else if (currency == 'BITCOIN') {
      _btcBalance += amount;
    } else if (currency == 'ETHEREUM') {
      _ethBalance += amount;
    }
    notifyListeners();
  }

  /// Withdraw from deposit
  void withdrawDeposit(String depositId, double amount) {
    try {
      final deposit = _deposits.firstWhere((d) => d['id'] == depositId);
      final currency = deposit['currency'];

      if (currency == 'USD') {
        _usdBalance += amount;
      } else if (currency == 'BITCOIN') {
        _btcBalance += amount;
      } else if (currency == 'ETHEREUM') {
        _ethBalance += amount;
      }

      deposit['status'] = 'withdrawn';
      notifyListeners();
    } catch (e) {
      print('Error withdrawing deposit: $e');
    }
  }

  /// Calculate daily profits for active deposits
  void calculateDailyProfits() {
    for (var deposit in _deposits) {
      if (deposit['status'] == 'active') {
        final tariffData = deposit['tariffData'];
        final avgProfit = tariffData['avgProfit'];
        final amount = deposit['amount'];

        deposit['dailyProfit'] = amount * avgProfit;
        deposit['totalProfit'] =
            (deposit['totalProfit'] ?? 0.0) + deposit['dailyProfit'];
      }
    }
    notifyListeners();
  }

  /// Clear subscription messages
  void clearSubscriptionMessages() {
    _subscriptionError = null;
    _subscriptionSuccess = null;
    notifyListeners();
  }

  /// Reset provider
  void reset() {
    _deposits = [];
    _subscriptionError = null;
    _subscriptionSuccess = null;
    _isSubscribing = false;
    notifyListeners();
  }
}