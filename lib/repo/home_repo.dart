import 'package:myinvestment/api_services/api_service.dart';
import 'package:myinvestment/utils/app_urls.dart';

import '../model/home_model/dashbord_model.dart';

class HomeRepository {
  final ApiService apiService;
  HomeRepository({required this.apiService});

  Future<DashboardDataModel> getDashBord() async {
    try {
      final response = await apiService.post(AppUrl.dashBordUrl);
      return DashboardDataModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
