import 'package:flutter/cupertino.dart';
import '../api_services/api_exception.dart';
import '../model/auth_model/login_response_model.dart';
import '../model/auth_model/user_register_model.dart';
import '../repo/auth_repo.dart';
import '../res/database/local_data_key.dart';
import '../res/database/local_database.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository authRepository;
  AuthController({required this.authRepository});

  // Auth state - Now stores the model object
  bool _isLoggedIn = false;
  UserData? _user; // Changed to store model directly
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

  // Initialize auth state from local storage
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // FIXED: Remove .key - pass enum directly
      final isLoggedIn = AppLocalData.getBool(LocalDataKey.isLoggedIn) ?? false;

      if (isLoggedIn) {
        // FIXED: Remove .key - pass enum directly
        final userData = AppLocalData.getMap(LocalDataKey.userData);
        final token = AppLocalData.getString(LocalDataKey.accessToken);

        if (userData != null && token != null) {
          _user = UserData.fromJson(userData);
          _isLoggedIn = true;
          print('✅ User loaded from storage: ${_user?.user?.name} (${_user?.user?.email})');
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

      // DEBUG PRINTS
      print('📊 Raw Response Status: ${response.status}');
      print('📊 Token: ${response.token}');
      print('📊 Message: ${response.message}');
      print('📊 User Data: ${response.data?.toJson()}');

      if (response.status == 0) {
        print('✅ Status check passed');

        if (response.token?.isEmpty ?? true) {
          print('❌ Token is empty');
          _errorMessage = 'Authentication token not received';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        print('✅ Token exists');

        if (response.data == null) {
          print('❌ User data is null');
          _errorMessage = response.message ?? 'User data not received';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        print('✅ User data exists');

        // Store the model directly
        _user = response.data;

        // FIXED: Remove .key - pass enum directly
        await AppLocalData.setString(LocalDataKey.accessToken, response.token!);
        print('✅ Token saved');

        // FIXED: Remove .key - pass enum directly
        await AppLocalData.setBool(LocalDataKey.isLoggedIn, true);
        print('✅ Login status saved');

        // FIXED: Remove .key - pass enum directly
        await AppLocalData.setMap(LocalDataKey.userData, response.data?.toJson() ?? {});
      //  print('✅ User data saved: ${_user?.name} (${_user?.email})');

        // Verify saved data
        final savedUserData = AppLocalData.getMap(LocalDataKey.userData);
        print('🔍 Verified saved user data: $savedUserData');

        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
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
      print('❌ Stack trace: ${StackTrace.current}');
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
          print('❌ Registration response missing user data');
          _errorMessage = response.message ?? 'Registration failed. Please try again.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        print('❌ Registration failed: ${response.status}');
        _errorMessage = response.message ?? 'Registration failed. Please try again.';
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

  Future<void> logout() async {
    try {
      // FIXED: Remove .key - pass enum directly
      await AppLocalData.remove(LocalDataKey.isLoggedIn);
      await AppLocalData.remove(LocalDataKey.userData);
      await AppLocalData.remove(LocalDataKey.accessToken);

      _user = null;
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

      // FIXED: Remove .key - pass enum directly
      final isLoggedIn = AppLocalData.getBool(LocalDataKey.isLoggedIn);
      final userData = AppLocalData.getMap(LocalDataKey.userData);
      final token = AppLocalData.getString(LocalDataKey.accessToken);

      print('🔍 isLoggedIn: $isLoggedIn');
      print('🔍 userData: $userData');
      print('🔍 token: $token');

      if (isLoggedIn == true && userData != null) {
        _user = UserData.fromJson(userData);
        _isLoggedIn = true;
       // print('✅ User loaded: ${_user?.name} (${_user?.email})');
        notifyListeners();
      } else {
        print('⚠️ No user data found in storage');
      }
    } catch (e) {
      print('❌ Error loading user from storage: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}