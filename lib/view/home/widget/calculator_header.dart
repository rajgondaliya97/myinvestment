import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../res/app_widget/custom_app_text.dart';
import '../../../../utils/app_color.dart';

class CalculatorHeader extends StatelessWidget {
  final Animation<double> floatAnimation;

  const CalculatorHeader({
    Key? key,
    required this.floatAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, floatAnimation.value),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColor.primaryColor.withOpacity(0.15),
                  AppColor.lighterGreen.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: AppColor.primaryColor.withOpacity(0.3),
                width: 1.5.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildIconContainer(),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildTitleSection(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconContainer() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor,
            AppColor.lighterGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.trending_up_rounded,
        color: Colors.white,
        size: 28.sp,
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.large(
          'Calculate Returns',
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
        SizedBox(height: 4.h),
        AppText.small(
          'Real-time profit calculations',
          color: Colors.grey[400],
          fontSize: 13,
        ),
      ],
    );
  }
}