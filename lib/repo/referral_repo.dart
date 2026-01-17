import '../api_services/api_service.dart';
import '../utils/app_urls.dart';

class ReferralRepository {
  final ApiService apiService;
  ReferralRepository({required this.apiService});

  /// Fetch referral data organized by levels
  Future<dynamic> getReferralLevelwise() async {
    try {
      // It uses apiService.get because the cURL you provided was a GET request
      final response = await apiService.get(AppUrl.myReferralsLevelwise);

      // If you have created the Model (ReferralLevelModel), use it here:
      // return ReferralLevelModel.fromJson(response);

      return response;
    } catch (e) {
      rethrow;
    }
  }
}