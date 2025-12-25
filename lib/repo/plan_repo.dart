import '../api_services/api_service.dart';
import '../model/plan_model/get_plan_model.dart';
import '../utils/app_urls.dart';

class PlanRepository {
  final ApiService apiService;
  PlanRepository({required this.apiService});

  /// Fetch all available investment plans from the API
  Future<GetPlanModel> getPlans() async {
    try {
      final response = await apiService.get(AppUrl.getPlansUrl);
      return GetPlanModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch a single plan by ID
  Future<GetPlanModel> getPlanById({required int planId}) async {
    try {
      final response = await apiService.get("${AppUrl.getPlansByIdUrl}$planId");
      return GetPlanModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
