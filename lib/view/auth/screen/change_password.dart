import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_flush_bar.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../res/app_widget/custom_text_field.dart';
import '../../../utils/app_color.dart';
import '../../../view_model/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    // 1. Check Confirm Password (Good practice as it's in your UI)
    if (_newPasswordController.text != _confirmPasswordController.text) {
      FlushbarHelper.showError(context: context, message: "Passwords do not match");
      return;
    }

    final authController = context.read<AuthController>();

    final success = await authController.changePassword(
      oldPassword: _oldPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // 2. Show the success message first
      FlushbarHelper.showSuccess(
        context: context,
        message: 'Password updated successfully!',
      );

      // 3. WAIT before popping. This prevents the Navigator collision
      // and lets the user see the success message.
      Future.delayed(const Duration(seconds: 2), () {
       // if (mounted) {
        //  Navigator.of(context).pop();
    //    }
      });

    } else {
      FlushbarHelper.showError(
        context: context,
        message: authController.errorMessage ?? 'Failed to update password',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondaryPrimaryColor,
      appBar: const CustomAppBar(title: 'Change Password', showDrawer: false),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppColor.screenGradientBgColor),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo(),
                SizedBox(height: 30.h),

                // Current Password
                _LabelText(label: 'Old Password'),
                CustomTextField(
                  hint: 'Enter Old password',
                  controller: _oldPasswordController,
                  icon: Icons.lock_open_rounded,
                ),
                SizedBox(height: 20.h),

                // New Password
                _LabelText(label: 'New Password'),
                CustomTextField(
                  hint: 'Enter new password',
                  controller: _newPasswordController,
                  icon: Icons.lock_outline_rounded,
                  ),
                SizedBox(height: 20.h),

                // Confirm Password
                _LabelText(label: 'Confirm New Password'),
                CustomTextField(
                  hint: 'Confirm new password',
                  controller: _confirmPasswordController,
                  icon: Icons.check_circle_outline_rounded,
                ),
                SizedBox(height: 40.h),

                // Submit Button
                Consumer<AuthController>(
                  builder: (context, auth, _) {
                    return AppButton.primary(
                      onPressed: auth.isLoading ? null : _handleChangePassword,
                      text: auth.isLoading ? 'Updating...' : 'Update Password',
                      width: double.infinity,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisibilityToggle(bool isObscured, VoidCallback onTap) {
    return IconButton(
      icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20.sp),
      onPressed: onTap,
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.lighterGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.lighterGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: AppColor.lighterGreen, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: AppText.medium(
              'Update your password regularly to keep your account secure.',
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelText extends StatelessWidget {
  final String label;
  const _LabelText({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: AppText.medium(label, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
    );
  }
}