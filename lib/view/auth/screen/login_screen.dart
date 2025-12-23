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
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Clear errors when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthController>(context, listen: false).clearLoginErrors();
    });
  }

  void _handleLogin() async {
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

              // Email Field - Error from controller
              CustomTextField(
                hint: 'Email Address',
                icon: Icons.email_outlined,
                controller: _emailController,
                errorText: authController.emailError,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20.h),

              // Password Field - Error from controller
              CustomTextField(
                hint: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
                errorText: authController.passwordError,
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

              // Login Button - Loading state from controller
              AppButton.primary(
                onPressed: authController.isLoading ? null : _handleLogin,
                text: 'Login',
                isLoading: authController.isLoading,
                icon: Icons.login,
              ),
              SizedBox(height: 24.h),

              // Register Link - Uses controller method
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText.medium(
                    "Don't have an account? ",
                    color: Colors.grey[600],
                  ),
                  GestureDetector(
                    onTap: () => authController.toggleAuthScreen(),
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