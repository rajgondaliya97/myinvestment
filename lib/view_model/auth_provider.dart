import 'package:flutter/cupertino.dart';
import '../res/database/local_data_key.dart';
import '../res/database/local_database.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  bool _isInitialized = false;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Initialize auth state from local storage
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user is logged in
      final isLoggedIn = AppLocalData.getBool(LocalDataKey.isLoggedIn) ?? false;

      if (isLoggedIn) {
        // Load user data from local storage
        final userData = AppLocalData.getMap(LocalDataKey.userData);
        if (userData != null) {
          _user = userData;
          _isLoggedIn = true;
        }
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      // Create user data
      _user = {
        'email': email,
        'name': email.split('@')[0],
        'profileImage': null,
      };

      // Save to local storage
      await AppLocalData.setBool(LocalDataKey.isLoggedIn, true);
      await AppLocalData.setMap(LocalDataKey.userData, _user!);

      _isLoggedIn = true;
    } catch (e) {
      print('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      // Create user data
      _user = {
        'email': email,
        'name': name,
        'profileImage': null,
      };

      // Save to local storage
      await AppLocalData.setBool(LocalDataKey.isLoggedIn, true);
      await AppLocalData.setMap(LocalDataKey.userData, _user!);

      _isLoggedIn = true;
    } catch (e) {
      print('Registration error: $e');
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
}