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
            gradient: AppColor.glassGradient,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: widget.errorText != null
                  ? AppColor.error
                  : AppColor.primaryColor.withOpacity(0.3),
              width: 2.w,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword && _obscureText,
            keyboardType: widget.keyboardType,
            style: TextStyle(color: AppColor.white, fontSize: 16.sp),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle:
              TextStyle(color: AppColor.grey500, fontSize: 16.sp),
              prefixIcon: Icon(widget.icon,
                  color: AppColor.white.withOpacity(0.7), size: 20.sp),
              suffixIcon: widget.isPassword
                  ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColor.white.withOpacity(0.7),
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
            child: AppText.small(widget.errorText!, color: AppColor.error),
          ),
      ],
    );
  }
}