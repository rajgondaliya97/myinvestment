import '../api_services/api_service.dart';
import '../model/auth_model/login_response_model.dart';
import '../utils/app_urls.dart';

class AuthRepository {
  final ApiService apiService;
  AuthRepository({required this.apiService});

  Future<LoginResponseModel> loginUser({
    required String email,
    required String password,
  }) async
  {
    try {
      final response = await apiService.post(
        AppUrl.loginUrl,
        body: {'email': email, 'password': password},
      );
      return LoginResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}