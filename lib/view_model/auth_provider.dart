import 'package:flutter/cupertino.dart';
import '../api_services/api_exception.dart';
import '../model/auth_model/login_response_model.dart';
import '../model/auth_model/update_user_profile_model.dart';
import '../model/auth_model/user_profile_model.dart';
import '../model/auth_model/user_register_model.dart';
import '../repo/auth_repo.dart';
import '../res/database/local_data_key.dart';
import '../res/database/local_database.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository authRepository;
  AuthController({required this.authRepository});

  // Auth state
  bool _isLoggedIn = false;
  UserData? _user;
  UserProfileModelData? _profileData; // NEW: Profile data from API
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  bool _showLoginScreen = true;

  // Login validation errors
  String? _emailError;
  String? _passwordError;

  // Register validation errors
  String? _firstNameError;
  String? _lastNameError;
  String? _confirmPasswordError;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  UserData? get user => _user;
  UserProfileModelData? get profileData => _profileData; // NEW: Profile data getter
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get showLoginScreen => _showLoginScreen;

  // Login error getters
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;

  // Register error getters
  String? get firstNameError => _firstNameError;
  String? get lastNameError => _lastNameError;
  String? get confirmPasswordError => _confirmPasswordError;

  // Toggle between login and register screens
  void toggleAuthScreen() {
    _showLoginScreen = !_showLoginScreen;
    clearLoginErrors();
    clearRegisterErrors();
    notifyListeners();
  }

  // Clear login validation errors
  void clearLoginErrors() {
    _emailError = null;
    _passwordError = null;
    notifyListeners();
  }

  // Clear register validation errors
  void clearRegisterErrors() {
    _firstNameError = null;
    _lastNameError = null;
    _emailError = null;
    _passwordError = null;
    _confirmPasswordError = null;
    notifyListeners();
  }

  // NEW: Fetch user profile from API
  Future<void> fetchUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📡 Fetching user profile from API...');

      final response = await authRepository.getUserProfile();

      print('📊 Profile Response Status: ${response.status}');
      print('📊 Profile Message: ${response.message}');
      print('📊 Profile Data: ${response.data?.toJson()}');

      if (response.status == 0 && response.data != null) {
        _profileData = response.data;

        // Update user data in storage with profile data
        final userData = _user?.toJson() ?? {};
        userData['user'] = response.data?.toJson();

        await AppLocalData.setMap(LocalDataKey.userData, userData);

        print('✅ Profile data fetched and saved');
        print('✅ Name: ${_profileData?.firstName} ${_profileData?.lastName}');
        print('✅ Email: ${_profileData?.email}');
        print('✅ Wallet Balance: ${_profileData?.walletBalance}');

        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Failed to fetch profile';
        print('❌ Profile fetch failed: $_errorMessage');
      }
    } on ApiException catch (e) {
      print('❌ ApiException: ${e.message}');
      _errorMessage = e.message;
    } catch (e) {
      print('❌ Exception: $e');
      _errorMessage = 'Failed to fetch profile data';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Initialize auth state from local storage
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = AppLocalData.getBool(LocalDataKey.isLoggedIn) ?? false;

      if (isLoggedIn) {
        final token = AppLocalData.getString(LocalDataKey.accessToken);

        if (token != null) {
          _isLoggedIn = true;
          print('✅ User loaded from storage: ${_profileData?.email}');
        } else {
          await logout();
        }
      }
    } catch (e) {
      print('❌ Error initializing auth: $e');
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  // Validate login inputs
  bool _validateLogin(String email, String password) {
    clearLoginErrors();
    bool isValid = true;

    if (email.isEmpty) {
      _emailError = 'Email is required';
      isValid = false;
    } else if (!email.contains('@')) {
      _emailError = 'Please enter a valid email';
      isValid = false;
    }

    if (password.isEmpty) {
      _passwordError = 'Password is required';
      isValid = false;
    } else if (password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      isValid = false;
    }

    if (!isValid) {
      notifyListeners();
    }

    return isValid;
  }

  Future<bool> login(String email, String password) async {
    if (!_validateLogin(email, password)) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await authRepository.loginUser(
        email: email,
        password: password,
      );

      print('📊 Raw Response Status: ${response.status}');
      print('📊 Token: ${response.token}');
      print('📊 Message: ${response.message}');

      if (response.status == 0) {
        print('✅ Status check passed');

        if (response.token?.isEmpty ?? true) {
          print('❌ Token is empty');
          _errorMessage = 'Authentication token not received';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        if (response.data == null) {
          print('❌ User data is null');
          _errorMessage = response.message ?? 'User data not received';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        _user = response.data;

        await AppLocalData.setString(LocalDataKey.accessToken, response.token.toString());
        await AppLocalData.setBool(LocalDataKey.isLoggedIn, true);
        await AppLocalData.setMap(LocalDataKey.userData, response.data?.toJson() ?? {});

        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();

        // Fetch profile after successful login
        await fetchUserProfile();

        return true;

      } else {
        print('❌ Status check failed: ${response.status}');
        _errorMessage = response.message ?? 'Login failed. Please check your credentials.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

    } on ApiException catch (e) {
      print('❌ ApiException: ${e.message}');
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Exception: $e');
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Validate register inputs
  bool _validateRegister(String firstName, String lastName, String email, String password, String confirmPassword) {
    clearRegisterErrors();
    bool isValid = true;

    if (firstName.isEmpty) {
      _firstNameError = 'First name is required';
      isValid = false;
    }

    if (lastName.isEmpty) {
      _lastNameError = 'Last name is required';
      isValid = false;
    }

    if (email.isEmpty) {
      _emailError = 'Email is required';
      isValid = false;
    } else if (!email.contains('@')) {
      _emailError = 'Please enter a valid email';
      isValid = false;
    }

    if (password.isEmpty) {
      _passwordError = 'Password is required';
      isValid = false;
    } else if (password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      isValid = false;
    }

    if (confirmPassword != password) {
      _confirmPasswordError = 'Passwords do not match';
      isValid = false;
    }

    if (!isValid) {
      notifyListeners();
    }

    return isValid;
  }

  Future<bool> register(String firstName, String lastName, String email, String password, String confirmPassword, String? referralCode) async {
    if (!_validateRegister(firstName, lastName, email, password, confirmPassword)) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userRegisterModel = UserRegisterModel(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        referralCode: referralCode,
      );

      final response = await authRepository.singUpUser(
        userRegisterModel: userRegisterModel,
      );

      print('📊 Registration Status: ${response.status}');
      print('📊 Registration Message: ${response.message}');

      if (response.status == 0) {
        if (response.data?.userId != null) {
          print('✅ Registration successful');
          _showLoginScreen = true;
          _errorMessage = null;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = response.message ?? 'Registration failed. Please try again.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = response.message ?? 'Registration failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await AppLocalData.remove(LocalDataKey.isLoggedIn);
      await AppLocalData.remove(LocalDataKey.userData);
      await AppLocalData.remove(LocalDataKey.accessToken);

      _user = null;
      _profileData = null;
      _isLoggedIn = false;
      _errorMessage = null;
      _showLoginScreen = true;
      clearLoginErrors();
      clearRegisterErrors();
      notifyListeners();
      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout error: $e');
    }
  }

  Future<void> loadUserFromStorage() async {
    try {
      print('🔍 Loading user data from storage...');

      final isLoggedIn = AppLocalData.getBool(LocalDataKey.isLoggedIn);
      //final userData = AppLocalData.getMap(LocalDataKey.userData);
      final token = AppLocalData.getString(LocalDataKey.accessToken);

      if (isLoggedIn == true) {

        _isLoggedIn = true;
        notifyListeners();
      } else {
        print('⚠️ No user data found in storage');
      }
    } catch (e) {
      print('❌ Error loading user from storage: $e');
    }
  }
// Add this method to your AuthController class

// Update user profile - does not store data locally
  Future<bool> updateUserProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? profileImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📡 Updating user profile...');

      final response = await authRepository.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        profileImage: profileImage,
      );

      print('📊 Update Response Status: ${response.status}');
      print('📊 Update Message: ${response.message}');
      print('📊 Update Data: ${response.data?.toJson()}');

      if (response.status == 0 && response.data != null) {
        print('✅ Profile updated successfully');

        // Fetch updated profile data from API after successful update
        await fetchUserProfile();

        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to update profile';
        print('❌ Profile update failed: $_errorMessage');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      print('❌ ApiException: ${e.message}');
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Exception: $e');
      _errorMessage = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}