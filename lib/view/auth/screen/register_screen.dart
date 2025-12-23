import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../res/app_widget/custom_app_button.dart';
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

  @override
  void initState() {
    super.initState();
    // Clear errors when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthController>(context, listen: false).clearRegisterErrors();
    });
  }

  void _handleRegister() {
    final authController = Provider.of<AuthController>(context, listen: false);

    authController.register(
      _firstNameController.text,
      _lastNameController.text,
      _emailController.text,
      _passwordController.text,
      _confirmPasswordController.text,
      _referralCodeController.text.isNotEmpty ? _referralCodeController.text : null,
    );
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
                      size: 60.sp
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              AppText.large('Create Account', fontWeight: FontWeight.w700),
              SizedBox(height: 8.h),
              AppText.medium('Start your investment journey', color: Colors.grey[600]),
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
                      color: Colors.grey[600]
                  ),
                  GestureDetector(
                    onTap: () => authController.toggleAuthScreen(),
                    child: AppText.medium(
                        'Login',
                        color: Color(0xFF00FF00),
                        fontWeight: FontWeight.w700
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }
}