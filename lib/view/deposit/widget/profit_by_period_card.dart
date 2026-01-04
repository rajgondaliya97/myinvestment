import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../utils/app_color.dart';

class ProfitByPeriodCard extends StatelessWidget {
  final TextEditingController amountController;
  final Map<String, dynamic> tariffData;

  const ProfitByPeriodCard({
    Key? key,
    required this.amountController,
    required this.tariffData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(amountController.text) ?? 0;
    final weeklyProfit = (amount * tariffData['avgProfit']) * 7;
    final totalProfit = (amount * tariffData['avgProfit']) * tariffData['days'];

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColor.lighterGreen.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            'PROFIT BY PERIOD',
            fontSize: 12,
            color: Colors.grey[400],
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 16.h),
          _buildProfitBox(
            weeklyProfit.toStringAsFixed(2),
            'Weekly profit',
            isHighlight: true,
          ),
          SizedBox(height: 16.h),
          _buildProfitBox(
            totalProfit.toStringAsFixed(2),
            'Total profit',
            isHighlight: false,
          ),
        ],
      ),
    );
  }

  Widget _buildProfitBox(String value, String label, {required bool isHighlight}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: isHighlight
            ? LinearGradient(
          colors: [
            AppColor.primaryColor,
            AppColor.lighterGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : LinearGradient(
          colors: [
            AppColor.secondaryPrimaryColor.withOpacity(0.8),
            AppColor.primaryColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          AppText.large(
            value,
            fontSize: isHighlight ? 28 : 24,
            fontWeight: FontWeight.w700,
            color: isHighlight ? Colors.white : AppColor.lighterGreen,
          ),
          SizedBox(height: 4.h),
          AppText.medium(
            'USD',
            fontSize: 12,
            color: isHighlight ? Colors.white.withOpacity(0.85) : Colors.grey[400],
          ),
          SizedBox(height: 8.h),
          AppText.medium(
            label,
            fontSize: 13,
            color: isHighlight ? Colors.white.withOpacity(0.85) : Colors.grey[400],
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}