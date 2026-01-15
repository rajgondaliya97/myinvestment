import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../res/app_widget/custom_app_text.dart';
import '../../../utils/app_color.dart';

class ConnectWalletCard extends StatelessWidget {
  final VoidCallback? onTap;

  const ConnectWalletCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          gradient: AppColor.cardGradientBgColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.green.withOpacity(0.5),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            // Wallet Icon
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 25.sp,
              ),
            ),

            SizedBox(width: 16.w),

            // Text Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.large(
                    'Connect Your Wallet',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 4.h),
                  AppText.large(
                    'Import your MetaMask wallet to Deposit',
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10,
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
