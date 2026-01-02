import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_flush_bar.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../res/app_widget/custom_text_field.dart';
import '../../../view_model/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referralCodeController = TextEditingController();

  // Theme colors
  static const Color primaryGreen = Color(0xFF116713);
  static const Color primaryBlue = Color(0xFF031c40);

  @override
  void initState() {
    super.initState();
    // Clear errors when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthController>(context, listen: false).clearRegisterErrors();
    });
  }

  void _handleRegister() async {
    final authController = Provider.of<AuthController>(context, listen: false);

    final success = await authController.register(
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _confirmPasswordController.text,
      _referralCodeController.text.isNotEmpty ? _referralCodeController.text.trim() : null,
    );

    // Show appropriate flushbar
    if (mounted) {
      if (success) {
        FlushbarHelper.showSuccess(
          context: context,
          message: 'Account created successfully! Please log in to continue.',
          title: 'Registration Successful',
        );
        // The controller has already switched to login screen
      } else {
        FlushbarHelper.showError(
          context: context,
          message: authController.errorMessage ?? 'Registration failed',
          title: 'Registration Failed',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryBlue,
              primaryGreen.withOpacity(0.3),
              primaryBlue,
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
                        size: 60.sp
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                AppText.large('Create Account', fontWeight: FontWeight.w700),
                SizedBox(height: 8.h),
                AppText.medium('Start your investment journey', color: Colors.grey[400]),
                SizedBox(height: 40.h),

                // First Name Field - Error from controller
                CustomTextField(
                  hint: 'First Name',
                  icon: Icons.person_outline,
                  controller: _firstNameController,
                  errorText: authController.firstNameError,
                ),
                SizedBox(height: 20.h),

                // Last Name Field - Error from controller
                CustomTextField(
                  hint: 'Last Name',
                  icon: Icons.person_outline,
                  controller: _lastNameController,
                  errorText: authController.lastNameError,
                ),
                SizedBox(height: 20.h),

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
                SizedBox(height: 20.h),

                // Confirm Password Field - Error from controller
                CustomTextField(
                  hint: 'Confirm Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: _confirmPasswordController,
                  errorText: authController.confirmPasswordError,
                ),
                SizedBox(height: 20.h),

                // Referral Code Field
                CustomTextField(
                  hint: 'Referral Code (Optional)',
                  icon: Icons.card_giftcard_outlined,
                  controller: _referralCodeController,
                ),
                SizedBox(height: 32.h),

                // Register Button - Loading state from controller
                AppButton.primary(
                  onPressed: authController.isLoading ? null : _handleRegister,
                  text: 'Create Account',
                  isLoading: authController.isLoading,
                  icon: Icons.person_add,
                ),
                SizedBox(height: 24.h),

                // Login Link - Uses controller method
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText.medium(
                        "Already have an account? ",
                        color: Colors.grey[400]
                    ),
                    GestureDetector(
                      onTap: () => authController.toggleAuthScreen(),
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [primaryGreen, primaryGreen.withValues(alpha: 0.9)],
                        ).createShader(bounds),
                        child: AppText.medium(
                            'Login',
                            color: Colors.white,
                            fontWeight: FontWeight.w700
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }
}