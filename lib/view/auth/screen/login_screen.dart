import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_flush_bar.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../res/app_widget/custom_text_field.dart';
import '../../../view_model/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSwitchToRegister;
  const LoginScreen({Key? key, required this.onSwitchToRegister}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  void _handleLogin() async {
    // Clear previous errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validate email
    if (_emailController.text.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return;
    }
    if (!_emailController.text.contains('@')) {
      setState(() => _emailError = 'Please enter a valid email');
      return;
    }

    // Validate password
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      return;
    }

    // Call login API
    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    // Show appropriate flushbar
    if (mounted) {
      if (success) {
        FlushbarHelper.showSuccess(
          context: context,
          message: 'Welcome back! Login successful.',
          title: 'Success',
        );
      } else {
        FlushbarHelper.showError(
          context: context,
          message: authController.errorMessage ?? 'Login failed',
          title: 'Login Failed',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              Center(
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF00FF00).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: Color(0xFF00FF00),
                    size: 60.sp,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              AppText.large(
                'Welcome Back!',
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: 8.h),
              AppText.medium(
                'Login to continue investing',
                color: Colors.grey[600],
              ),
              SizedBox(height: 40.h),

              // Email Field
              CustomTextField(
                hint: 'Email Address',
                icon: Icons.email_outlined,
                controller: _emailController,
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20.h),

              // Password Field
              CustomTextField(
                hint: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
                errorText: _passwordError,
              ),
              SizedBox(height: 12.h),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: AppButton.text(
                  onPressed: () {
                    // TODO: Implement forgot password
                  },
                  text: 'Forgot Password?',
                ),
              ),
              SizedBox(height: 24.h),

              // Login Button
              AppButton.primary(
                onPressed: authController.isLoading ? null : _handleLogin,
                text: 'Login',
                isLoading: authController.isLoading,
                icon: Icons.login,
              ),
              SizedBox(height: 24.h),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText.medium(
                    "Don't have an account? ",
                    color: Colors.grey[600],
                  ),
                  GestureDetector(
                    onTap: widget.onSwitchToRegister,
                    child: AppText.medium(
                      'Register',
                      color: Color(0xFF00FF00),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}