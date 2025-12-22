import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../res/app_widget/custom_app_text.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double profitPercentage;

  const BalanceCard({
    Key? key,
    required this.balance,
    required this.profitPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF00FF00).withOpacity(0.2),
            Color(0xFF00CC00).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Color(0xFF00FF00).withOpacity(0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.medium(
                'Total Balance',
                color: Colors.grey[400],
                fontSize: 12,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: profitPercentage >= 0
                      ? Color(0xFF00FF00).withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      profitPercentage >= 0
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: profitPercentage >= 0
                          ? Color(0xFF00FF00)
                          : Colors.red,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    AppText.small(
                      '${profitPercentage.toStringAsFixed(1)}%',
                      color: profitPercentage >= 0
                          ? Color(0xFF00FF00)
                          : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AppText.large(
            '\$${balance.toStringAsFixed(2)}',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          SizedBox(height: 8.h),
          AppText.small(
            fontSize: 10,
            'Available for withdrawal',
            color: Colors.grey[500],
          ),
        ],
      ),
    );
  }
}