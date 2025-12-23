import 'package:flutter/foundation.dart';

class DepositProvider extends ChangeNotifier {
  double _usdBalance = 26.75;
  double _btcBalance = 0.0;
  double _ethBalance = 0.0;

  List<Map<String, dynamic>> _deposits = [];

  // Getters
  double get usdBalance => _usdBalance;
  double get btcBalance => _btcBalance;
  double get ethBalance => _ethBalance;
  double get totalBalance => _usdBalance + (_btcBalance * 50000) + (_ethBalance * 3000); // Approximate conversions
  List<Map<String, dynamic>> get deposits => _deposits;

  // Create new deposit
  void createDeposit({
    required String currency,
    required double amount,
    required String tariff,
    required Map<String, dynamic> tariffData,
  }) {
    // Deduct amount from balance
    if (currency == 'USD') {
      _usdBalance -= amount;
    } else if (currency == 'BITCOIN') {
      _btcBalance -= amount;
    } else if (currency == 'ETHEREUM') {
      _ethBalance -= amount;
    }

    // Create deposit record
    final now = DateTime.now();
    final expiryDate = now.add(Duration(days: tariffData['days']));

    final deposit = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'currency': currency,
      'amount': amount,
      'tariff': tariff,
      'tariffData': tariffData,
      'openDate': now,
      'expiryDate': expiryDate,
      'status': 'active',
      'dailyProfit': 0.0,
      'totalProfit': 0.0,
    };

    _deposits.add(deposit);
    notifyListeners();
  }

  // Update balance
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

  // Withdraw from deposit
  void withdrawDeposit(String depositId, double amount) {
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
  }

  // Calculate daily profit for active deposits
  void calculateDailyProfits() {
    for (var deposit in _deposits) {
      if (deposit['status'] == 'active') {
        final tariffData = deposit['tariffData'];
        final avgProfit = tariffData['avgProfit'];
        final amount = deposit['amount'];

        deposit['dailyProfit'] = amount * avgProfit;
        deposit['totalProfit'] = (deposit['totalProfit'] ?? 0.0) + deposit['dailyProfit'];
      }
    }
    notifyListeners();
  }

  // Get active deposits count
  int get activeDepositsCount {
    return _deposits.where((d) => d['status'] == 'active').length;
  }

  // Get total invested amount
  double get totalInvested {
    return _deposits
        .where((d) => d['status'] == 'active')
        .fold(0.0, (sum, d) => sum + (d['amount'] as double));
  }

  // Get total profit earned
  double get totalProfitEarned {
    return _deposits.fold(0.0, (sum, d) => sum + ((d['totalProfit'] ?? 0.0) as double));
  }
}