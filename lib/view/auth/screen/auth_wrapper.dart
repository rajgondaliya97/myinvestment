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
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoggedIn) {
      return HomeScreen();
    }

    return showLogin
        ? LoginScreen(onSwitchToRegister: () => setState(() => showLogin = false))
        : RegisterScreen(onSwitchToLogin: () => setState(() => showLogin = true));
  }
}