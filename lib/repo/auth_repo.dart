import '../api_services/api_service.dart';
import '../model/auth_model/login_response_model.dart';
import '../model/auth_model/sing_up_response_model.dart';
import '../model/auth_model/user_profile_model.dart';
import '../model/auth_model/user_register_model.dart';
import '../utils/app_urls.dart';

class AuthRepository {
  final ApiService apiService;
  AuthRepository({required this.apiService});

  Future<LoginResponseModel> loginUser({
    required String email,
    required String password,
  }) async {
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

  Future<SingUpResponseModel> singUpUser({
    required UserRegisterModel userRegisterModel,
  }) async {
    try {
      final response = await apiService.post(
        AppUrl.registerUrl,
        body: userRegisterModel.toJson(),
      );
      return SingUpResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserProfileModel> getUserProfile() async {
    try {
      final response = await apiService.get(AppUrl.userProfileUrl);

      return UserProfileModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
