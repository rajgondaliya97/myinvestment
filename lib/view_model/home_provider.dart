import 'package:flutter/material.dart';
import '../model/home_model/dashbord_model.dart';
import '../repo/home_repo.dart';

class HomeProvider extends ChangeNotifier {
  final HomeRepository homeRepository;

  HomeProvider({required this.homeRepository});

  // Dashboard data
  DashboardDataModel? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  DashboardDataModel? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get balance from dashboard data
  double get balance => (_dashboardData?.balance ?? 0).toDouble();
  int get activePlans => _dashboardData?.activePlans ?? 0;
  int get totalWithdrawalsApprove => _dashboardData?.totalWithdrawalsApprove ?? 0;
  int get totalWithdrawals => _dashboardData?.totalWithdrawals ?? 0;

  // Chart data (keep existing implementation)
  String _selectedPeriod = '1M';
  String get selectedPeriod => _selectedPeriod;

  List<double> get currentChartData {
    // Return your existing chart data based on selected period
    return _getChartDataForPeriod(_selectedPeriod);
  }

  double get profitPercentage {
    // Calculate profit percentage based on your logic
    return 12.5; // Example value
  }

  // Fetch dashboard data from API
  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardData = await homeRepository.getDashBord();
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Select period for chart
  void selectPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  // Initialize with user data (optional - for backward compatibility)
  void initializeWithUserData({
    double? walletBalance,
    double? investmentAmount,
  }) {
    // You can use this if needed for initial display before API loads
    notifyListeners();
  }

  // Helper method to get chart data
  List<double> _getChartDataForPeriod(String period) {
    // Your existing chart data logic - returning just the profit values
    switch (period) {
      case '1W':
        return [120, 150, 170, 140, 200, 180, 190];
      case '1M':
        return [800, 1200, 1500, 1800];
      case '3M':
        return [5000, 6500, 7200];
      case '1Y':
        return [5000, 5500, 6000, 6200, 7000, 7500, 8000, 8200, 8500, 9000, 9500, 10000];
      default:
        return [800, 1200, 1500, 1800];
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await fetchDashboardData();
  }
}