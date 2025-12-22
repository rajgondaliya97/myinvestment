import 'package:flutter/cupertino.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: 2));

    _user = {
      'email': email,
      'name': email.split('@')[0],
      'profileImage': null,
    };
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: 2));

    _user = {
      'email': email,
      'name': name,
      'profileImage': null,
    };
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}