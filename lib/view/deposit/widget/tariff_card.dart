import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../res/app_widget/custom_app_text.dart';

class TariffCard extends StatelessWidget {
  final String selectedTariff;
  final Function(String) onTariffChanged;

  const TariffCard({
    Key? key,
    required this.selectedTariff,
    required this.onTariffChanged,
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
            'TARIFF',
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 16.h),
          _buildTariffOption('basic', 'Basic', '1-1.5% / 15 days'),
          SizedBox(height: 12.h),
          _buildTariffOption('advanced', 'Advanced', '1.5-2% / 25 days'),
          SizedBox(height: 12.h),
          _buildTariffOption('professional', 'Professional', '2-3% / 30 days'),
        ],
      ),
    );
  }

  Widget _buildTariffOption(String key, String title, String subtitle) {
    bool isSelected = selectedTariff == key;
    return GestureDetector(
      onTap: () => onTariffChanged(key),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00FF00).withOpacity(0.15)
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF00FF00) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.medium(
                  title,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? const Color(0xFF00FF00) : Colors.white,
                ),
                SizedBox(height: 4.h),
                AppText.medium(
                  subtitle,
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ],
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF00FF00) : Colors.grey[600],
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }
}