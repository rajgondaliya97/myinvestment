import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  double _balance = 125450.75;
  double _profitPercentage = 24.5;
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

    _balance += 100; // Demo: add some profit
    _profitPercentage = ((_balance / 100000) - 1) * 100;
    _isLoading = false;
    notifyListeners();
  }
}