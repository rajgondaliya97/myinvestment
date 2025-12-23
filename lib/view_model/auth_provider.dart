import 'package:flutter/cupertino.dart';
import '../api_services/api_exception.dart';
import '../repo/auth_repo.dart';
import '../res/database/local_data_key.dart';
import '../res/database/local_database.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository authRepository;
  AuthController({required this.authRepository});

  bool _isLoggedIn = false;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  // Initialize auth state from local storage
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user is logged in
      final isLoggedIn = AppLocalData.getBool(LocalDataKey.isLoggedIn) ?? false;

      if (isLoggedIn) {
        // Load user data and token from local storage
        final userData = AppLocalData.getMap(LocalDataKey.userData);
        final token = AppLocalData.getString(LocalDataKey.accessToken);

        if (userData != null && token != null) {
          _user = userData;
          _isLoggedIn = true;
        } else {
          // Clear invalid data
          await logout();
        }
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call the login API
      final response = await authRepository.loginUser(
        email: email,
        password: password,
      );

      // Check if response and status are valid
      if (response.status != null && (response.status == 200 || response.status == 1)) {

        // Check if token exists
        if (response.token == null || response.token!.isEmpty) {
          _errorMessage = 'Authentication token not received';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Check if user data exists
        if (response.data == null) {
          _errorMessage = response.message ?? 'User data not received';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Save token to local storage
        await AppLocalData.setString(LocalDataKey.accessToken, response.token!);

        // Prepare user data from LoginResponseModelData
        _user = {
          'id': response.data?.id,
          'email': response.data?.email,
          'name': response.data?.name,
          'firstName': response.data?.firstName,
          'lastName': response.data?.lastName,
          'phone': response.data?.phone,
          'role': response.data?.role,
          'country': response.data?.country,
          'address': response.data?.address,
          'walletBalance': response.data?.walletBalance,
          'investmentAmount': response.data?.investmentAmount,
          'referralCode': response.data?.referralCode,
          'referredBy': response.data?.referredBy,
          'isVerified': response.data?.isVerified,
          'emailVerifiedAt': response.data?.emailVerifiedAt,
          'idProof': response.data?.idProof,
          'lastLogin': response.data?.lastLogin,
          'createdAt': response.data?.createdAt,
          'updatedAt': response.data?.updatedAt,
          'profileImage': null,
        };

        // Save to local storage
        await AppLocalData.setBool(LocalDataKey.isLoggedIn, true);
        await AppLocalData.setMap(LocalDataKey.userData, _user!);

        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;

      } else {
        // Handle error response
        _errorMessage = response.message ?? 'Login failed. Please check your credentials.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

    } on ApiException catch (e) {
      // API exceptions are already handled by ApiService
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Login error: $e');
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> register(String firstName, String lastName, String email, String password, String? referralCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement register API call when available
      // For now, using simulation
      await Future.delayed(Duration(seconds: 2));

      // Create user data
      _user = {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'name': '$firstName $lastName',
        'referredBy': referralCode,
        'profileImage': null,
      };

      // Save to local storage
      await AppLocalData.setBool(LocalDataKey.isLoggedIn, true);
      await AppLocalData.setMap(LocalDataKey.userData, _user!);

      _isLoggedIn = true;
    } catch (e) {
      print('Registration error: $e');
      _errorMessage = 'Registration failed. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      // Clear local storage
      await AppLocalData.remove(LocalDataKey.isLoggedIn);
      await AppLocalData.remove(LocalDataKey.userData);
      await AppLocalData.remove(LocalDataKey.accessToken);

      _user = null;
      _isLoggedIn = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> updatedData) async {
    try {
      if (_user != null) {
        _user = {..._user!, ...updatedData};
        await AppLocalData.setMap(LocalDataKey.userData, _user!);
        notifyListeners();
      }
    } catch (e) {
      print('Update profile error: $e');
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}