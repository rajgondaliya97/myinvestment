import 'package:flutter/foundation.dart';
import '../model/plan_model/get_plan_by_id_model.dart';
import '../model/plan_model/get_plan_model.dart';
import '../repo/plan_repo.dart';

class PlanProvider extends ChangeNotifier {
  final PlanRepository planRepository;

  List<GetPlanModelData>? _plans;
  GetPlanByIdModelData? _selectedPlanDetails;
  bool _isLoading = false;
  bool _isLoadingDetails = false;
  String? _errorMessage;

  // Getters
  List<GetPlanModelData>? get plans => _plans;
  GetPlanByIdModelData? get selectedPlanDetails => _selectedPlanDetails;
  bool get isLoading => _isLoading;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  PlanProvider({required this.planRepository});

  /// Fetch all plans from API
  Future<void> fetchPlans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await planRepository.getPlans();

      if (response.status == 1 && response.data != null && response.data!.isNotEmpty) {
        _plans = response.data;
        _errorMessage = null;

        // Auto-select first plan and fetch its details
        print('✅ Plans fetched: ${_plans!.length} plans available');
        print('🔄 Auto-selecting first plan...');

        if (_plans != null && _plans!.isNotEmpty) {
          final firstPlan = _plans!.first;
          await fetchPlanDetailsById(firstPlan.id ?? 0);
          print('✅ First plan auto-selected: ${firstPlan.name}');
        }
      } else {
        _errorMessage = response.message ?? 'Failed to fetch plans';
        _plans = null;
        _selectedPlanDetails = null;
        print('❌ Failed to fetch plans: ${_errorMessage}');
      }
    } catch (e) {
      _errorMessage = 'Error fetching plans: ${e.toString()}';
      _plans = null;
      _selectedPlanDetails = null;
      print('❌ Error fetching plans: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch detailed plan information by ID
  Future<void> fetchPlanDetailsById(int planId) async {
    _isLoadingDetails = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📡 Fetching plan details for ID: $planId');

      final response = await planRepository.getPlanById(planId: planId);

      if (response.status == 0  && response.data != null) {
        _selectedPlanDetails = response.data;
        _errorMessage = null;

        print('✅ Plan details fetched:');
        print('   Name: ${_selectedPlanDetails?.name}');
        print('   Min Amount: ${_selectedPlanDetails?.minAmount}');
        print('   Max Amount: ${_selectedPlanDetails?.maxAmount}');
        print('   ROI: ${_selectedPlanDetails?.dailyRoi}%');
        print('   Duration: ${_selectedPlanDetails?.durationDays} days');
        print('   Description: ${_selectedPlanDetails?.description}');
      } else {
        _errorMessage = response.message ?? 'Plan not found';
        _selectedPlanDetails = null;
        print('❌ Failed to fetch plan details: ${_errorMessage}');
      }
    } catch (e) {
      _errorMessage = 'Error fetching plan: ${e.toString()}';
      _selectedPlanDetails = null;
      print('❌ Error fetching plan details: $e');
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset provider
  void reset() {
    _plans = null;
    _selectedPlanDetails = null;
    _isLoading = false;
    _isLoadingDetails = false;
    _errorMessage = null;
    notifyListeners();
  }
}