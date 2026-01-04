import 'package:flutter/material.dart';
import 'package:myinvestment/view/auth/screen/register_screen.dart';
import 'package:provider/provider.dart';

import '../../../view_model/auth_provider.dart';
import '../../home/screen/home_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize auth state when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthController>(context, listen: false).initializeAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    // Show loading screen while checking auth state
    if (!authController.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF00FF00).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: Color(0xFF00FF00),
                  size: 60,
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF00)),
              ),
            ],
          ),
        ),
      );
    }

    // Show home screen if logged in
    if (authController.isLoggedIn) {
      return HomeScreen();
    }

    // Show login or register screen based on controller state
    return authController.showLoginScreen
        ? LoginScreen()
        : RegisterScreen();
  }
}