import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../res/app_widget/custom_app_text.dart';

class PlanDetailsCard extends StatelessWidget {
  final Map<String, dynamic> tariffData;

  const PlanDetailsCard({
    Key? key,
    required this.tariffData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final expiryDate = now.add(Duration(days: tariffData['days']));

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
            'PLAN DETAILS',
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 16.h),
          _buildDetailRow('Open date', _formatDate(now)),
          SizedBox(height: 12.h),
          _buildDetailRow('Expire date', _formatDate(expiryDate)),
          SizedBox(height: 12.h),
          _buildDetailRow('Accrual of profit', 'Monday - Friday'),
          SizedBox(height: 12.h),
          _buildDetailRow('Withdrawal of funds', 'Monday - Friday'),
          SizedBox(height: 12.h),
          _buildDetailRow('Deposit term', '${tariffData['days']} days'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.medium(fontSize: 13, label, color: Colors.grey[500]),
        AppText.medium(
          value,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
  }
}