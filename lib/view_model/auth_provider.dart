import 'package:flutter/cupertino.dart';
import '../api_services/api_exception.dart';
import '../repo/auth_repo.dart';
import '../res/database/local_data_key.dart';
import '../res/database/local_database.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository authRepository;
  AuthController({required this.authRepository});

  // Auth state
  bool _isLoggedIn = false;
  Map<String, dynamic>? _user;
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
  Map<String, dynamic>? get user => _user;
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

  // Validate login inputs
  bool _validateLogin(String email, String password) {
    clearLoginErrors();
    bool isValid = true;

    // Validate email
    if (email.isEmpty) {
      _emailError = 'Email is required';
      isValid = false;
    } else if (!email.contains('@')) {
      _emailError = 'Please enter a valid email';
      isValid = false;
    }

    // Validate password
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
    // Validate inputs first
    if (!_validateLogin(email, password)) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call the login API
      final response = await authRepository.loginUser(
        email: email,
        password: password,
      );

      // ADD THESE DEBUG PRINTS
      print('📊 Raw Response Status: ${response.status}');
      print('📊 Status Type: ${response.status.runtimeType}');
      print('📊 Status == 200: ${response.status == 200}');
      print('📊 Status == 1: ${response.status == 1}');
      print('📊 Token: ${response.token}');
      print('📊 Data: ${response.data}');
      print('📊 Message: ${response.message}');

      // Check if response and status are valid
      if (response.status == 0) {
        print('✅ Status check passed');

        // Check if token exists
        if (response.token?.isEmpty ?? true) {
          print('🔴 Token is empty');
          _errorMessage = 'Authentication token not received';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        print('✅ Token exists: ${response.token}');

        // Check if user data exists
        if (response.data == null) {
          print('🔴 User data is null');
          _errorMessage = response.message ?? 'User data not received';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        print('✅ User data exists');

        // Save token to local storage
        await AppLocalData.setString(LocalDataKey.accessToken, response.token!);
        print('✅ Token saved to local storage');

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
        await AppLocalData.setMap(LocalDataKey.userData, _user ?? {});
        print('✅ User data saved to local storage');

        _isLoggedIn = true;
        _isLoading = false;
        print('✅ Login successful, isLoggedIn: $_isLoggedIn');
        notifyListeners();
        return true;

      }
      else {
        print('🔴 Status check failed');
        // Handle error response
        _errorMessage = response.message ?? 'Login failed. Please check your credentials.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

    } on ApiException catch (e) {
      print('🔴 ApiException: ${e.message}');
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('🔴 Exception: $e');
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

    // Validate first name
    if (firstName.isEmpty) {
      _firstNameError = 'First name is required';
      isValid = false;
    }

    // Validate last name
    if (lastName.isEmpty) {
      _lastNameError = 'Last name is required';
      isValid = false;
    }

    // Validate email
    if (email.isEmpty) {
      _emailError = 'Email is required';
      isValid = false;
    } else if (!email.contains('@')) {
      _emailError = 'Please enter a valid email';
      isValid = false;
    }

    // Validate password
    if (password.isEmpty) {
      _passwordError = 'Password is required';
      isValid = false;
    } else if (password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      isValid = false;
    }

    // Validate confirm password
    if (confirmPassword != password) {
      _confirmPasswordError = 'Passwords do not match';
      isValid = false;
    }

    if (!isValid) {
      notifyListeners();
    }

    return isValid;
  }

  Future<void> register(String firstName, String lastName, String email, String password, String confirmPassword, String? referralCode) async {
    // Validate inputs first
    if (!_validateRegister(firstName, lastName, email, password, confirmPassword)) {
      return;
    }

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
      _showLoginScreen = true;
      clearLoginErrors();
      clearRegisterErrors();
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