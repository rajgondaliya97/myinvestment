import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  double _balance = 0.0;
  double _profitPercentage = 0.0;
  String _selectedPeriod = '1D';
  bool _isLoading = false;

  // Chart data for different periods
  Map<String, List<double>> _chartData = {
    '1D': [100, 120, 115, 140, 135, 150, 145, 160, 155, 170],
    '1W': [1000, 1100, 1050, 1200, 1150, 1300, 1250],
    '1M': [5000, 5500, 5300, 6000, 5800, 6500, 6300, 7000],
    '1Y': [50000, 60000, 55000, 70000, 65000, 80000, 75000, 90000, 85000, 100000, 95000, 110000],
  };

  double get balance => _balance;
  double get profitPercentage => _profitPercentage;
  String get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;
  List<double> get currentChartData => _chartData[_selectedPeriod] ?? [];

  /// Initialize home data with user data from login
  void initializeWithUserData({
    required String? walletBalance,
    required String? investmentAmount,
  }) {
    try {
      // Parse wallet balance
      _balance = double.tryParse(walletBalance ?? '0') ?? 0.0;

      // Parse investment amount
      final investment = double.tryParse(investmentAmount ?? '0') ?? 0.0;

      // Calculate profit percentage
      if (investment > 0) {
        _profitPercentage = ((_balance - investment) / investment) * 100;
      } else {
        _profitPercentage = 0.0;
      }

      print('💰 Balance initialized: $_balance');
      print('📈 Profit percentage: $_profitPercentage%');

      notifyListeners();
    } catch (e) {
      print('Error initializing user data: $e');
    }
  }

  void selectPeriod(String period) {
    _selectedPeriod = period;
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    Future.delayed(Duration(milliseconds: 500), () {
      _isLoading = false;
      notifyListeners();
    });
  }

  void refreshData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    // In real app, fetch updated balance from API
    _balance += 100; // Demo: add some profit

    // Recalculate profit
    if (_balance > 0) {
      _profitPercentage = (_profitPercentage + 1.0).clamp(0.0, 100.0);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update balance from external source
  void updateBalance(double newBalance) {
    _balance = newBalance;
    notifyListeners();
  }

  /// Reset to default values
  void reset() {
    _balance = 0.0;
    _profitPercentage = 0.0;
    _selectedPeriod = '1D';
    _isLoading = false;
    notifyListeners();
  }
}