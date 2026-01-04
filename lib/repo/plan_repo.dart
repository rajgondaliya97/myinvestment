import '../api_services/api_service.dart';
import '../model/plan_model/get_plan_by_id_model.dart';
import '../model/plan_model/get_plan_model.dart';
import '../model/plan_model/plan_subscribe_model.dart';
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
  Future<GetPlanByIdModel> getPlanById({required int planId}) async {
    try {
      final response = await apiService.get("${AppUrl.getPlansByIdUrl}$planId");
      return GetPlanByIdModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Plan Subscribe

  Future<PlanSubscribeModel> planSubscribe({
    required String plan_id,
    required amount,
  }) async {
    try {
      final response = await apiService.post(
        AppUrl.planSubscribeUrl,
        body: {"plan_id": plan_id, "amount": amount},
      );
      return PlanSubscribeModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
