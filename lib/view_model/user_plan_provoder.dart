import 'package:flutter/cupertino.dart';
import '../api_services/api_exception.dart';
import '../model/user_plan/user_plan_model.dart';
import '../repo/plan_repo.dart';

class UserPlanController extends ChangeNotifier {
  final PlanRepository planRepository;
  UserPlanController({required this.planRepository});

  // User Plans State
  List<UserPlanModelData> _userPlans = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  int _perPage = 10;
  int _total = 0;
  bool _hasMoreData = true;

  // Getters
  List<UserPlanModelData> get userPlans => _userPlans;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  bool get hasMoreData => _hasMoreData;

  // Get active plans only
  List<UserPlanModelData> get activePlans {
    return _userPlans.where((plan) => plan.status?.toLowerCase() == 'active').toList();
  }

  // Get completed plans only
  List<UserPlanModelData> get completedPlans {
    return _userPlans.where((plan) => plan.status?.toLowerCase() == 'completed').toList();
  }

  // Get expired plans only
  List<UserPlanModelData> get expiredPlans {
    return _userPlans.where((plan) => plan.status?.toLowerCase() == 'expired').toList();
  }

  /// Fetch user plans (first page or refresh)
  Future<void> fetchUserPlans({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _userPlans.clear();
      _hasMoreData = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📡 Fetching user plans - Page: $_currentPage');

      final response = await planRepository.getUserPlan(_perPage, _currentPage);

      print('📊 User Plans Response Status: ${response.status}');
      print('📊 Total Plans: ${response.pagination?.total}');

      if (response.status == 0 && response.data != null) {
        if (refresh) {
          _userPlans = response.data!;
        } else {
          _userPlans.addAll(response.data!);
        }

        // Update pagination info
        if (response.pagination != null) {
          _currentPage = response.pagination!.currentPage ?? 1;
          _lastPage = response.pagination!.lastPage ?? 1;
          _perPage = response.pagination!.perPage ?? 10;
          _total = response.pagination!.total ?? 0;
          _hasMoreData = _currentPage < _lastPage;
        }

        print('✅ Loaded ${_userPlans.length} plans');
        print('✅ Active Plans: ${activePlans.length}');
        print('✅ Has More Data: $_hasMoreData');

        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to fetch plans';
        print('❌ Plans fetch failed');
      }
    } on ApiException catch (e) {
      print('❌ ApiException: ${e.message}');
      _errorMessage = e.message;
    } catch (e) {
      print('❌ Exception: $e');
      _errorMessage = 'Failed to load plans';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load more plans (pagination)
  Future<void> loadMorePlans() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      print('📡 Loading more plans - Page: $_currentPage');

      final response = await planRepository.getUserPlan(_perPage, _currentPage);

      if (response.status == 0 && response.data != null) {
        _userPlans.addAll(response.data!);

        if (response.pagination != null) {
          _currentPage = response.pagination!.currentPage ?? _currentPage;
          _lastPage = response.pagination!.lastPage ?? _lastPage;
          _hasMoreData = _currentPage < _lastPage;
        }

        print('✅ Loaded more plans. Total: ${_userPlans.length}');
      }
    } on ApiException catch (e) {
      print('❌ Load more failed: ${e.message}');
      _currentPage--; // Revert page increment
    } catch (e) {
      print('❌ Load more exception: $e');
      _currentPage--; // Revert page increment
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Calculate total investment amount
  double get totalInvestment {
    return _userPlans.fold(0.0, (sum, plan) => sum + (plan.amount ?? 0).toDouble());
  }

  /// Calculate total interest earned
  double get totalInterestEarned {
    return _userPlans.fold(0.0, (sum, plan) => sum + (plan.totalInterest ?? 0).toDouble());
  }

  /// Calculate total daily interest
  double get totalDailyInterest {
    return activePlans.fold(0.0, (sum, plan) => sum + (plan.dailyInterest ?? 0).toDouble());
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearPlans() {
    _userPlans.clear();
    _currentPage = 1;
    _hasMoreData = true;
    notifyListeners();
  }
}