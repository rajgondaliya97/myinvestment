import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/app_color.dart';
import 'custom_app_text.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final String? errorText;
  final TextInputType? keyboardType;

  const CustomTextField({
    Key? key,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    required this.controller,
    this.errorText,
    this.keyboardType,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor.secondaryPrimaryColor.withOpacity(0.8),
                AppColor.lighterBlue.withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: widget.errorText != null
                  ? Colors.red
                  : AppColor.primaryColor.withOpacity(0.3),
              width: 2.w,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword && _obscureText,
            keyboardType: widget.keyboardType,
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle:
              TextStyle(color: Colors.grey[500], fontSize: 16.sp),
              prefixIcon: Icon(widget.icon,
                  color: AppColor.primaryColor.withOpacity(0.7), size: 20.sp),
              suffixIcon: widget.isPassword
                  ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColor.primaryColor.withOpacity(0.7),
                  size: 20.sp,
                ),
                onPressed: () =>
                    setState(() => _obscureText = !_obscureText),
              )
                  : null,
              border: InputBorder.none,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            ),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: EdgeInsets.only(left: 8.w, top: 8.h),
            child: AppText.small(widget.errorText!, color: Colors.red),
          ),
      ],
    );
  }
}