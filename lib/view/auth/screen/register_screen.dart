import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_widget/custom_app_button.dart';
import '../../../utils/app_widget/custom_app_text.dart';
import '../../../utils/app_widget/custom_text_field.dart';
import '../../../view_model/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onSwitchToLogin;
  const RegisterScreen({Key? key, required this.onSwitchToLogin}) : super(key: key);
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  void _handleRegister() {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });
    if (_nameController.text.isEmpty) {
      setState(() => _nameError = 'Name is required');
      return;
    }
    if (_emailController.text.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return;
    }
    if (!_emailController.text.contains('@')) {
      setState(() => _emailError = 'Please enter a valid email');
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      return;
    }
    if (_confirmPasswordController.text != _passwordController.text) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      return;
    }
    Provider.of<AuthProvider>(context, listen: false).register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
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
                  child: Icon(Icons.trending_up, color: Color(0xFF00FF00), size: 60.sp),
                ),
              ),
              SizedBox(height: 40.h),
              AppText.large('Create Account', fontWeight: FontWeight.w700),
              SizedBox(height: 8.h),
              AppText.medium('Start your investment journey', color: Colors.grey[600]),
              SizedBox(height: 40.h),
              CustomTextField(
                hint: 'Full Name',
                icon: Icons.person_outline,
                controller: _nameController,
                errorText: _nameError,
              ),
              SizedBox(height: 20.h),
              CustomTextField(
                hint: 'Email Address',
                icon: Icons.email_outlined,
                controller: _emailController,
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20.h),
              CustomTextField(
                hint: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
                errorText: _passwordError,
              ),
              SizedBox(height: 20.h),
              CustomTextField(
                hint: 'Confirm Password',
                icon: Icons.lock_outline,
                isPassword: true,
                controller: _confirmPasswordController,
                errorText: _confirmPasswordError,
              ),
              SizedBox(height: 32.h),
              AppButton.primary(
                onPressed: _handleRegister,
                text: 'Create Account',
                isLoading: authProvider.isLoading,
                icon: Icons.person_add,
              ),
              SizedBox(height: 16.h),
              AppButton.secondary(
                onPressed: () {},
                text: 'Sign up with Apple',
                icon: Icons.apple,
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText.medium("Already have an account? ", color: Colors.grey[600]),
                  GestureDetector(
                    onTap: widget.onSwitchToLogin,
                    child: AppText.medium('Login', color: Color(0xFF00FF00), fontWeight: FontWeight.w700),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}