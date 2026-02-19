import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/view/informetiv_screens/InformetiveHome_screen.dart';
import 'package:provider/provider.dart';

import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_flush_bar.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../res/app_widget/custom_text_field.dart';
import '../../../view_model/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  /// Optional email to pre-fill (e.g. when navigated from WebView login button)
  final String? prefillEmail;

  const LoginScreen({Key? key, this.prefillEmail}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Theme colors
  static const Color primaryGreen = Color(0xFF116713);
  static const Color primaryBlue = Color(0xFF031c40);

  @override
  void initState() {
    super.initState();
    // Pre-fill email if provided (from WebView navigation)
    if (widget.prefillEmail != null && widget.prefillEmail!.isNotEmpty) {
      _emailController.text = widget.prefillEmail!;
    }
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

    if (!mounted) return;

    if (success) {
      FlushbarHelper.showSuccess(
        context: context,
        message: 'Welcome back! Login successful.',
        title: 'Success',
      );

      // Navigate to home screen, replacing the entire back-stack
      // so user can't go back to the login screen
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const InformetiveHomeScreen()),
          (route) => false,
        );
      }
    } else {
      FlushbarHelper.showError(
        context: context,
        message: authController.errorMessage ?? 'Login failed',
        title: 'Login Failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryBlue,
              primaryGreen.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
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
                      gradient: LinearGradient(
                        colors: [
                          primaryGreen.withOpacity(0.2),
                          primaryBlue.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: primaryGreen.withOpacity(0.3),
                        width: 2.w,
                      ),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: primaryGreen,
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
                  color: Colors.grey[400],
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

                /*// Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton.text(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    text: 'Forgot Password?',
                  ),
                ),*/
                SizedBox(height: 24.h),

                // Login Button - Loading state from controller
                AppButton.primary(
                  onPressed: authController.isLoading ? null : _handleLogin,
                  text: 'Login',
                  isLoading: authController.isLoading,
                  icon: Icons.login,
                  height: 50.h,
                  fontSize: 15,
                ),
                SizedBox(height: 24.h),

                // Register Link - Uses controller method
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText.medium(
                      "Don't have an account? ",
                      color: Colors.grey[400],
                    ),
                    GestureDetector(
                      onTap: () => authController.toggleAuthScreen(),
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [primaryGreen, primaryGreen.withValues(alpha: 0.9)],
                        ).createShader(bounds),
                        child: AppText.medium(
                          'Register',
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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