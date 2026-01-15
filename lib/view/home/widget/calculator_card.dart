import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/app_color.dart';
import '../../../res/app_widget/custom_app_text.dart';

class CalculatorCard extends StatelessWidget {
  final VoidCallback onCalculatorTap;

  const CalculatorCard({
    super.key,
    required this.onCalculatorTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCalculatorTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.secondaryPrimaryColor.withOpacity(0.8),
              AppColor.primaryColor.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColor.primaryColor.withOpacity(0.3),
            width: 1.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            AppText.medium(
              'Investment Calculator',
              fontWeight: FontWeight.w700,
              color: AppColor.white,
              fontSize: 14,
            ),

            SizedBox(height: 8.h),

            // Description
            AppText.medium(
              'Calculate your investment returns and plan your financial future with instant results.',
              color: Colors.white.withOpacity(0.85),
              fontSize: 10,
            ),

            SizedBox(height: 15.h),

            // Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5.w,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText.small(
                    'Start Calculating',
                    color: AppColor.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppColor.white,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}