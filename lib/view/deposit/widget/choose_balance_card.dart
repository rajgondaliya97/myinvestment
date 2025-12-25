import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../res/app_widget/custom_app_text.dart';

class ChooseBalanceCard extends StatelessWidget {
  final String selectedCurrency;
  final Function(String) onCurrencyChanged;
  final double usdBalance;
  final double btcBalance;
  final double ethBalance;

  const ChooseBalanceCard({
    Key? key,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
    required this.usdBalance,
    required this.btcBalance,
    required this.ethBalance,
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
            'CHOOSE BALANCE',
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 16.h),
          _buildBalanceOption('USD', usdBalance, Icons.attach_money,
              selectedCurrency == 'USD'),
          SizedBox(height: 12.h),
          _buildBalanceOption('BITCOIN', btcBalance, Icons.currency_bitcoin,
              selectedCurrency == 'BITCOIN'),
          SizedBox(height: 12.h),
          _buildBalanceOption('ETHEREUM', ethBalance,
              Icons.currency_exchange, selectedCurrency == 'ETHEREUM'),
        ],
      ),
    );
  }

  Widget _buildBalanceOption(
      String currency, double balance, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => onCurrencyChanged(currency),
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
          children: [
            Container(
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                color:
                isSelected ? const Color(0xFF00FF00) : const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.black : Colors.grey[600],
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.medium(
                    currency,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                    isSelected ? const Color(0xFF00FF00) : Colors.grey[400],
                  ),
                  SizedBox(height: 4.h),
                  AppText.medium(
                    balance.toStringAsFixed(currency == 'USD' ? 2 : 8),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
