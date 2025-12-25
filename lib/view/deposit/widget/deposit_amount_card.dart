import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../res/app_widget/custom_app_text.dart';

class DepositAmountCard extends StatelessWidget {
  final TextEditingController controller;
  final Map<String, dynamic> tariffData;

  const DepositAmountCard({
    Key? key,
    required this.controller,
    required this.tariffData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            'DEPOSIT AMOUNT',
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFF00FF00).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '1000',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                ),
                AppText.medium(
                  'USD',
                  fontSize: 16,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          _buildAmountLimitRow('MIN AMOUNT', tariffData['minAmount']),
          SizedBox(height: 6.h),
          _buildAmountLimitRow('MAX AMOUNT', tariffData['maxAmount']),
        ],
      ),
    );
  }

  Widget _buildAmountLimitRow(String label, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.medium(
          label,
          fontSize: 13,
          color: Colors.grey[600],
        ),
        AppText.medium(
          '$value',
          fontSize: 13,
          color: const Color(0xFF00FF00),
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }
}
