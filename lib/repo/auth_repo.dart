import '../api_services/api_service.dart';
import '../model/auth_model/login_response_model.dart';
import '../model/auth_model/logout_model.dart';
import '../model/auth_model/sing_up_response_model.dart';
import '../model/auth_model/user_profile_model.dart';
import '../model/auth_model/user_register_model.dart';
import '../model/auth_model/update_user_profile_model.dart';
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

  Future<UpdateUserProfileModel> updateUserProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? profileImage, // base64 encoded image or file path
  }) async {
    try {
      final body = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      };

      // Add profile image if provided
      if (profileImage != null && profileImage.isNotEmpty) {
        body['profile'] = profileImage;
      }

      final response = await apiService.post(
        AppUrl.updateUserProfileUrl, // Make sure this URL is defined in AppUrl
        body: body,
      );

      return UpdateUserProfileModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<LogoutModel> userLogout() async {
    try {
      final response = await apiService.get(AppUrl.logoutUrl);
      return LogoutModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await apiService.post(
        'api/reset_new_password',
        body: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
      // Assuming a standard response structure based on your other models
      return response;
    } catch (e) {
      rethrow;
    }
  }
}