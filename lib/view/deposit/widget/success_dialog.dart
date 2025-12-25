import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_text.dart';

class SuccessDialog extends StatelessWidget {
  final VoidCallback onDone;

  const SuccessDialog({
    Key? key,
    required this.onDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: const BorderSide(color: Color(0xFF00FF00), width: 2),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSuccessIcon(),
          SizedBox(height: 20.h),
          AppText.large(
            'Success!',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF00FF00),
          ),
          SizedBox(height: 12.h),
          AppText.medium(
            'You have successfully created new deposit',
            fontSize: 14,
            textAlign: TextAlign.center,
            color: Colors.grey[400],
          ),
        ],
      ),
      actions: [
        Center(
          child: AppButton.primary(
            onPressed: onDone,
            text: 'Done',
            width: 120,
            height: 45,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        color: const Color(0xFF00FF00).withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_circle,
        color: const Color(0xFF00FF00),
        size: 50.sp,
      ),
    );
  }
}