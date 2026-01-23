import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/utils/app_color.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../res/services/ReownWalletService.dart';
import 'network_data.dart';

class SingleNetworkDetails extends StatelessWidget {
  final ReownWalletService walletService;
  final String nativeBalance;
  final String usdtBalance;
  final String gasPrice;

  const SingleNetworkDetails({
    Key? key,
    required this.walletService,
    required this.nativeBalance,
    required this.usdtBalance,
    required this.gasPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nativeSymbol = NetworkData.getNativeSymbol(walletService.currentNetwork);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText.medium(
              'WALLET ASSETS',
              color: AppColor.grey500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            AppText.medium(
              'BALANCE',
              color: AppColor.grey500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        CurrencyItem(
          name: nativeSymbol,
          amount: double.parse(nativeBalance),
          icon: NetworkData.getNetworkIcon(walletService.currentNetwork),
          color: NetworkData.getNetworkColor(walletService.currentNetwork),
          symbol: nativeSymbol,
        ),
        SizedBox(height: 12.h),
        CurrencyItem(
          name: 'TETHER USD',
          amount: double.parse(usdtBalance),
          icon: Icons.monetization_on,
          color: Color(0xFF26A17B),
          symbol: 'USDT',
        ),
        SizedBox(height: 16.h),
        NetworkInfoRow(
          walletService: walletService,
          gasPrice: gasPrice,
        ),
      ],
    );
  }
}

class AllNetworksDetails extends StatelessWidget {
  final ReownWalletService walletService;
  final Map<String, double> allNativeBalances;
  final Map<String, double> allUsdtBalances;

  const AllNetworksDetails({
    Key? key,
    required this.walletService,
    required this.allNativeBalances,
    required this.allUsdtBalances,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText.medium(
              'ALL NETWORKS',
              color: AppColor.grey500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            AppText.medium(
              'BALANCE',
              color: AppColor.grey500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        SizedBox(height: 16.h),

        ...allNativeBalances.entries.map((entry) {
          final network = entry.key;
          final balance = entry.value;
          final symbol = NetworkData.getNativeSymbol(network);

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: NetworkBalanceRow(
              network: network,
              balance: balance,
              symbol: symbol,
              isActive: network == walletService.activeNetwork,
            ),
          );
        }).toList(),

        SizedBox(height: 16.h),

        AppText.medium(
          'USDT BALANCES',
          color: AppColor.grey500,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 12.h),

        ...allUsdtBalances.entries.map((entry) {
          final network = entry.key;
          final balance = entry.value;

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: NetworkBalanceRow(
              network: network,
              balance: balance,
              symbol: 'USDT',
              isActive: network == walletService.activeNetwork,
              isUsdt: true,
            ),
          );
        }).toList(),
      ],
    );
  }
}

class NetworkBalanceRow extends StatelessWidget {
  final String network;
  final double balance;
  final String symbol;
  final bool isActive;
  final bool isUsdt;

  const NetworkBalanceRow({
    Key? key,
    required this.network,
    required this.balance,
    required this.symbol,
    required this.isActive,
    this.isUsdt = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isActive
            ? NetworkData.getNetworkColor(network).withOpacity(0.1)
            : AppColor.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isActive
              ? NetworkData.getNetworkColor(network).withOpacity(0.5)
              : AppColor.grey500.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isUsdt ? Icons.monetization_on : NetworkData.getNetworkIcon(network),
            color: isUsdt ? Color(0xFF26A17B) : NetworkData.getNetworkColor(network),
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.small(
                  NetworkData.getNetworkDisplayName(network),
                  color: isActive ? AppColor.white : AppColor.grey300,
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                SizedBox(height: 2.h),
                AppText.medium(
                  '${balance.toStringAsFixed(isUsdt ? 2 : 4)} $symbol',
                  color: AppColor.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColor.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: AppText.small(
                'ACTIVE',
                color: AppColor.success,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class CurrencyItem extends StatelessWidget {
  final String name;
  final double amount;
  final IconData icon;
  final Color color;
  final String? symbol;

  const CurrencyItem({
    Key? key,
    required this.name,
    required this.amount,
    required this.icon,
    required this.color,
    this.symbol,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColor.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.small(
                  name,
                  color: AppColor.grey300.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 2.h),
                AppText.medium(
                  symbol != null && (symbol == 'ETH' || symbol == 'BNB' || symbol == 'MATIC')
                      ? amount.toStringAsFixed(4)
                      : amount.toStringAsFixed(2),
                  color: AppColor.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ],
            ),
          ),
          if (symbol != null)
            AppText.medium(
              symbol!,
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
        ],
      ),
    );
  }
}

class NetworkInfoRow extends StatelessWidget {
  final ReownWalletService walletService;
  final String gasPrice;

  const NetworkInfoRow({
    Key? key,
    required this.walletService,
    required this.gasPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColor.grey500.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.network_check,
                color: NetworkData.getNetworkColor(walletService.currentNetwork),
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.small(
                    'Active Network',
                    color: AppColor.grey500,
                    fontSize: 10,
                  ),
                  AppText.medium(
                    NetworkData.getNetworkDisplayName(walletService.currentNetwork),
                    color: AppColor.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ],
          ),
          if (gasPrice != '0')
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText.small(
                  'Gas Price',
                  color: AppColor.grey500,
                  fontSize: 10,
                ),
                AppText.medium(
                  '$gasPrice Gwei',
                  color: AppColor.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
        ],
      ),
    );
  }
}