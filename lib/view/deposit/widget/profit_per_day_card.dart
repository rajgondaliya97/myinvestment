import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../utils/app_color.dart';

class ProfitPerDayCard extends StatelessWidget {
  final Map<String, dynamic> tariffData;

  const ProfitPerDayCard({
    Key? key,
    required this.tariffData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.lighterGreen.withOpacity(0.3),
            AppColor.primaryColor.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColor.lighterGreen.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            'PROFIT PER DAY',
            fontSize: 12,
            color: Colors.grey[300],
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildProfitMetric(
                  'MINIMUM PROFIT',
                  '${tariffData['minProfit']} USD',
                  Icons.trending_down,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildProfitMetric(
                  'MAXIMUM PROFIT',
                  '${tariffData['maxProfit']} USD',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.secondaryPrimaryColor.withOpacity(0.8),
                  AppColor.primaryColor.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: AppColor.lighterGreen,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.medium(
                      'AVERAGE PROFIT',
                      fontSize: 11,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 4.h),
                    AppText.large(
                      '${tariffData['avgProfit']} USD',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.lighterGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitMetric(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.secondaryPrimaryColor.withOpacity(0.8),
            AppColor.primaryColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColor.lighterGreen, size: 20.sp),
          SizedBox(height: 8.h),
          AppText.medium(label, fontSize: 10, color: Colors.grey[400]),
          SizedBox(height: 4.h),
          AppText.medium(
            value,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}