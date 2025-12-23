// investment_provider.dart
import 'package:flutter/material.dart';

class InvestmentProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cryptoPlans = [];
  List<Map<String, dynamic>> _usdtPlans = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get cryptoPlans => _cryptoPlans;
  List<Map<String, dynamic>> get usdtPlans => _usdtPlans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch Crypto Plans from API
  Future<void> fetchCryptoPlans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      // Example: final response = await http.get(Uri.parse('your_api_url/crypto-plans'));

      // Simulating API delay
      await Future.delayed(Duration(seconds: 1));

      // Dummy data - Replace with actual API response parsing
      _cryptoPlans = [
        {
          'id': '1',
          'coinName': 'Bitcoin',
          'coinSymbol': 'BTC',
          'amount': 5000.00,
          'startDate': '2024-01-15',
          'endDate': '2024-07-15',
          'status': 'Active',
        },
        {
          'id': '2',
          'coinName': 'Ethereum',
          'coinSymbol': 'ETH',
          'amount': 3500.00,
          'startDate': '2024-02-01',
          'endDate': '2024-08-01',
          'status': 'Active',
        },
        {
          'id': '3',
          'coinName': 'Ripple',
          'coinSymbol': 'XRP',
          'amount': 2000.00,
          'startDate': '2023-12-01',
          'endDate': '2024-06-01',
          'status': 'Completed',
        },
        {
          'id': '4',
          'coinName': 'Cardano',
          'coinSymbol': 'ADA',
          'amount': 1500.00,
          'startDate': '2024-01-01',
          'endDate': '2024-04-01',
          'status': 'Pending',
        },
        {
          'id': '5',
          'coinName': 'Binance Coin',
          'coinSymbol': 'BNB',
          'amount': 4200.00,
          'startDate': '2024-03-10',
          'endDate': '2024-09-10',
          'status': 'Active',
        },
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load crypto plans. Please try again.';
      notifyListeners();
    }
  }

  // Fetch USDT Plans from API
  Future<void> fetchUsdtPlans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      // Example: final response = await http.get(Uri.parse('your_api_url/usdt-plans'));

      // Simulating API delay
      await Future.delayed(Duration(seconds: 1));

      // Dummy data - Replace with actual API response parsing
      _usdtPlans = [
        {
          'id': '1',
          'planName': 'USDT Premium Plan',
          'amount': 10000.00,
          'startDate': '2024-01-20',
          'endDate': '2024-07-20',
          'status': 'Active',
          'interestRate': 8.5,
        },
        {
          'id': '2',
          'planName': 'USDT Standard Plan',
          'amount': 5000.00,
          'startDate': '2024-02-15',
          'endDate': '2024-08-15',
          'status': 'Active',
          'interestRate': 6.0,
        },
        {
          'id': '3',
          'planName': 'USDT Basic Plan',
          'amount': 2500.00,
          'startDate': '2023-11-01',
          'endDate': '2024-05-01',
          'status': 'Completed',
          'interestRate': 5.5,
        },
        {
          'id': '4',
          'planName': 'USDT Growth Plan',
          'amount': 7500.00,
          'startDate': '2024-03-01',
          'endDate': '2024-09-01',
          'status': 'Pending',
          'interestRate': 7.2,
        },
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load USDT plans. Please try again.';
      notifyListeners();
    }
  }

  // Add a new crypto plan
  Future<void> addCryptoPlan(Map<String, dynamic> plan) async {
    try {
      // TODO: Make API call to add plan
      // Example: await http.post(Uri.parse('your_api_url/crypto-plans'), body: plan);

      _cryptoPlans.add(plan);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add crypto plan.';
      notifyListeners();
    }
  }

  // Add a new USDT plan
  Future<void> addUsdtPlan(Map<String, dynamic> plan) async {
    try {
      // TODO: Make API call to add plan
      // Example: await http.post(Uri.parse('your_api_url/usdt-plans'), body: plan);

      _usdtPlans.add(plan);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add USDT plan.';
      notifyListeners();
    }
  }

  // Update crypto plan status
  Future<void> updateCryptoPlanStatus(String planId, String newStatus) async {
    try {
      // TODO: Make API call to update status
      // Example: await http.put(Uri.parse('your_api_url/crypto-plans/$planId'), body: {'status': newStatus});

      final index = _cryptoPlans.indexWhere((plan) => plan['id'] == planId);
      if (index != -1) {
        _cryptoPlans[index]['status'] = newStatus;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update plan status.';
      notifyListeners();
    }
  }

  // Update USDT plan status
  Future<void> updateUsdtPlanStatus(String planId, String newStatus) async {
    try {
      // TODO: Make API call to update status
      // Example: await http.put(Uri.parse('your_api_url/usdt-plans/$planId'), body: {'status': newStatus});

      final index = _usdtPlans.indexWhere((plan) => plan['id'] == planId);
      if (index != -1) {
        _usdtPlans[index]['status'] = newStatus;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update plan status.';
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get plan by ID
  Map<String, dynamic>? getCryptoPlanById(String id) {
    try {
      return _cryptoPlans.firstWhere((plan) => plan['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic>? getUsdtPlanById(String id) {
    try {
      return _usdtPlans.firstWhere((plan) => plan['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Get total investment amount
  double getTotalCryptoInvestment() {
    return _cryptoPlans.fold(0.0, (sum, plan) => sum + (plan['amount'] ?? 0.0));
  }

  double getTotalUsdtInvestment() {
    return _usdtPlans.fold(0.0, (sum, plan) => sum + (plan['amount'] ?? 0.0));
  }

  // Get active plans count
  int getActiveCryptoPlansCount() {
    return _cryptoPlans.where((plan) => plan['status']?.toLowerCase() == 'active').length;
  }

  int getActiveUsdtPlansCount() {
    return _usdtPlans.where((plan) => plan['status']?.toLowerCase() == 'active').length;
  }
}