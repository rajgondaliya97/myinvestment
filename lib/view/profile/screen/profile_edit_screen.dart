import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_flush_bar.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../res/app_widget/custom_text_field.dart';
import '../../../utils/app_color.dart';
import '../../../view_model/auth_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _profileImage;
  String? _existingProfileUrl;
  bool _isLoading = false;

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthController>(context, listen: false);
    final profileData = authProvider.profileData;

    if (profileData != null) {
      _firstNameController.text = profileData.firstName ?? '';
      _lastNameController.text = profileData.lastName ?? '';
      _emailController.text = profileData.email ?? '';
      _existingProfileUrl = profileData.profile;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        FlushbarHelper.showError(
          context: context,
          message: 'Failed to pick image',
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
      if (mounted) {
        FlushbarHelper.showError(
          context: context,
          message: 'Failed to take photo',
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: AppColor.cardGradientBgColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            AppText.medium(
              'Choose Profile Photo',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            SizedBox(height: 20.h),
            _buildImageSourceOption(
              icon: Icons.photo_library,
              title: 'Gallery',
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            SizedBox(height: 12.h),
            _buildImageSourceOption(
              icon: Icons.camera_alt,
              title: 'Camera',
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            if (_profileImage != null || _existingProfileUrl != null) ...[
              SizedBox(height: 12.h),
              _buildImageSourceOption(
                icon: Icons.delete,
                title: 'Remove Photo',
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profileImage = null;
                    _existingProfileUrl = null;
                  });
                },
                isDelete: true,
              ),
            ],
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDelete = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.secondaryPrimaryColor.withOpacity(0.8),
              AppColor.primaryColor.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDelete
                ? Colors.red.withOpacity(0.5)
                : AppColor.lighterGreen.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDelete
                      ? [Colors.red.withOpacity(0.3), Colors.red.withOpacity(0.1)]
                      : [
                    AppColor.lighterGreen.withOpacity(0.3),
                    AppColor.primaryColor.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: isDelete ? Colors.red[400] : AppColor.lighterGreen,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            AppText.medium(
              title,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDelete ? Colors.red[400] : Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  bool _validateInputs() {
    bool isValid = true;

    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
    });

    if (_firstNameController.text.trim().isEmpty) {
      setState(() {
        _firstNameError = 'First name is required';
      });
      isValid = false;
    }

    if (_lastNameController.text.trim().isEmpty) {
      setState(() {
        _lastNameError = 'Last name is required';
      });
      isValid = false;
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailError = 'Email is required';
      });
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text.trim())) {
      setState(() {
        _emailError = 'Please enter a valid email';
      });
      isValid = false;
    }

    return isValid;
  }

  Future<String?> _convertImageToBase64() async {
    if (_profileImage == null) return null;

    try {
      final bytes = await _profileImage!.readAsBytes();
      final base64String = base64Encode(bytes);
      return base64String;
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  void _saveProfile() async {
    // Validate inputs
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthController>(context, listen: false);

      // Convert image to base64 if new image is selected
      String? profileImageData;
      if (_profileImage != null) {
        profileImageData = await _convertImageToBase64();
        if (profileImageData == null) {
          if (mounted) {
            FlushbarHelper.showError(
              context: context,
              message: 'Failed to process image',
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Call update profile API
      final success = await authProvider.updateUserProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        profileImage: profileImageData,
      );

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        // Show success flush bar
        FlushbarHelper.showSuccess(
          context: context,
          message: 'Profile updated successfully',
        );

        // Wait a moment for the flush bar to show, then navigate back
        await Future.delayed(Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else if (mounted) {
        final errorMessage = authProvider.errorMessage ?? 'Failed to update profile';
        FlushbarHelper.showError(
          context: context,
          message: errorMessage,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        FlushbarHelper.showError(
          context: context,
          message: 'An unexpected error occurred',
        );
      }
      print('Error saving profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondaryPrimaryColor,
      appBar: CustomAppBar(title: 'Edit Profile',showDrawer: false),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColor.screenGradientBgColor,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColor.lighterGreen.withOpacity(0.3),
                            AppColor.primaryColor.withOpacity(0.2),
                          ],
                        ),
                        border: Border.all(
                          color: AppColor.lighterGreen,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: _profileImage != null
                            ? Image.file(
                          _profileImage!,
                          fit: BoxFit.cover,
                        )
                            : _existingProfileUrl != null
                            ? Image.network(
                          _existingProfileUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 60.sp,
                              color: Colors.grey[600],
                            );
                          },
                        )
                            : Icon(
                          Icons.person,
                          size: 60.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColor.lighterGreen,
                                AppColor.primaryColor,
                              ],
                            ),
                            border: Border.all(
                              color: AppColor.secondaryPrimaryColor,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              // First Name Field
              CustomTextField(
                hint: 'Enter first name',
                icon: Icons.person_outline,
                controller: _firstNameController,
                errorText: _firstNameError,
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: 20.h),
              // Last Name Field
              CustomTextField(
                hint: 'Enter last name',
                icon: Icons.person_outline,
                controller: _lastNameController,
                errorText: _lastNameError,
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: 20.h),
              // Email Field
              CustomTextField(
                hint: 'Enter email address',
                icon: Icons.email_outlined,
                controller: _emailController,
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 40.h),
              // Save Button
              AppButton.primary(
                onPressed: _isLoading ? null : _saveProfile,
                text: _isLoading ? 'Saving...' : 'Save Changes',
                width: double.infinity,
                height: 55,
              ),
            ],
          ),
        ),
      ),
    );
  }
}