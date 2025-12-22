import '../api_services/api_service.dart';
import '../utils/app_urls.dart';

class AuthRepository {
  final ApiService apiService;
  AuthRepository({required this.apiService});

  /*Future<UserDataModel> loginUser({
    required String email,
    required String password,
  }) async
  {
    try {
      final response = await apiService.post(
        AppUrl.loginUrl,
        isLogin: true,
        body: {'email': email, 'password': password},
      );
      return UserDataModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }*/
}