import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../utils/app_color.dart';
import '../../../view_model/investment_controller.dart';
import '../../home/widget/custom_drawer.dart';

class CryptoPlanHistoryScreen extends StatefulWidget {
  const CryptoPlanHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CryptoPlanHistoryScreen> createState() => _CryptoPlanHistoryScreenState();
}

class _CryptoPlanHistoryScreenState extends State<CryptoPlanHistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvestmentProvider>(context, listen: false).fetchCryptoPlans();
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColor.lighterGreen;
      case 'completed':
        return Color(0xFF4A9DFF);
      case 'pending':
        return Color(0xFFFFB347);
      case 'cancelled':
        return Color(0xFFFF6B6B);
      default:
        return Colors.grey;
    }
  }

  IconData _getCoinIcon(String coinSymbol) {
    switch (coinSymbol.toUpperCase()) {
      case 'BTC':
        return Icons.currency_bitcoin;
      case 'ETH':
        return Icons.currency_exchange;
      case 'XRP':
        return Icons.waves;
      case 'ADA':
        return Icons.account_balance;
      case 'BNB':
        return Icons.local_fire_department;
      case 'SOL':
        return Icons.wb_sunny;
      case 'DOT':
        return Icons.circle;
      default:
        return Icons.monetization_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondaryPrimaryColor,
      appBar: const CustomAppBar(title: 'Crypto Plans History'),
      drawer: const CustomDrawer(currentRoute: 'crypto'),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColor.screenGradientBgColor,
        ),
        child: Consumer<InvestmentProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return _buildLoadingState();
            }

            if (provider.errorMessage != null) {
              return _buildErrorState(provider);
            }

            if (provider.cryptoPlans.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              color: AppColor.lighterGreen,
              backgroundColor: AppColor.lighterBlue,
              onRefresh: () => provider.fetchCryptoPlans(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                itemCount: provider.cryptoPlans.length,
                itemBuilder: (context, index) {
                  final plan = provider.cryptoPlans[index];
                  return _buildPlanCard(plan, index);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      AppColor.primaryColor.withOpacity(0.1),
                      AppColor.primaryColor,
                      AppColor.lighterGreen,
                      AppColor.primaryColor.withOpacity(0.1),
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                    transform: GradientRotation(
                      _shimmerController.value * 2 * 3.14159,
                    ),
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 68.w,
                    height: 68.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.secondaryPrimaryColor,
                    ),
                    child: Icon(
                      Icons.currency_bitcoin,
                      color: AppColor.primaryColor,
                      size: 32.sp,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24.h),
          AppText.medium(
            'Loading crypto plans...',
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(InvestmentProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColor.secondaryPrimaryColor.withOpacity(0.5),
                  AppColor.primaryColor.withOpacity(0.3),
                ],
              ),
            ),
            child: Icon(
              Icons.error_outline,
              size: 60.sp,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 16.h),
          AppText.medium(
            provider.errorMessage!,
            color: Colors.grey[300],
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.primaryColor, AppColor.lighterGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => provider.fetchCryptoPlans(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: AppText.medium(
                'Retry',
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColor.primaryColor.withOpacity(0.2),
                  AppColor.secondaryPrimaryColor.withOpacity(0.3),
                ],
              ),
              border: Border.all(
                color: AppColor.lighterGreen.withOpacity(0.3),
                width: 2.w,
              ),
            ),
            child: Icon(
              Icons.currency_bitcoin,
              size: 60.sp,
              color: AppColor.lighterGreen.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 24.h),
          AppText.large(
            'No Crypto Plans Yet',
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: 8.h),
          AppText.medium(
            'Your cryptocurrency investment\nhistory will appear here',
            color: Colors.grey[400],
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, int index) {
    final status = plan['status'] ?? 'Pending';
    final statusColor = _getStatusColor(status);
    final coinSymbol = plan['coinSymbol'] ?? '';
    final coinName = plan['coinName'] ?? 'Unknown';
    final amount = plan['amount']?.toStringAsFixed(2) ?? '0.00';
    final startDate = plan['startDate'] ?? 'N/A';
    final endDate = plan['endDate'] ?? 'N/A';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColor.lighterGreen.withOpacity(0.3),
          width: 1.5.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: AppColor.secondaryPrimaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with coin info
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primaryColor.withOpacity(0.4),
                  AppColor.secondaryPrimaryColor.withOpacity(0.3),
                  AppColor.primaryColor.withOpacity(0.2),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                // Coin Icon
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColor.lighterGreen,
                        AppColor.primaryColor,
                        AppColor.secondaryPrimaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.lighterGreen.withOpacity(0.5),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getCoinIcon(coinSymbol),
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                // Coin Name & Symbol
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.medium(
                        coinName,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColor.lighterGreen.withOpacity(0.3),
                              AppColor.primaryColor.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: AppText.small(
                          coinSymbol,
                          color: AppColor.lighterGreen,
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Chip
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(0.3),
                        statusColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: statusColor.withOpacity(0.5),
                      width: 1.w,
                    ),
                  ),
                  child: AppText.small(
                    status,
                    fontSize: 9,
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Plan Details
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Amount
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.secondaryPrimaryColor.withOpacity(0.8),
                        AppColor.primaryColor.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColor.lighterGreen.withOpacity(0.1),
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.small(
                            'Investment Amount',
                            fontSize: 10,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 4.h),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [AppColor.lighterGreen, AppColor.primaryColor],
                            ).createShader(bounds),
                            child: AppText.medium(
                              '\$$amount',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColor.lighterGreen.withOpacity(0.3),
                              AppColor.primaryColor.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.attach_money,
                          color: AppColor.lighterGreen,
                          size: 18.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Date Range
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.calendar_today,
                        label: 'Start Date',
                        value: startDate,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.event,
                        label: 'End Date',
                        value: endDate,
                      ),
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

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.secondaryPrimaryColor.withOpacity(0.8),
            AppColor.primaryColor.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColor.lighterGreen.withOpacity(0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.lighterGreen.withOpacity(0.3),
                      AppColor.primaryColor.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  icon,
                  size: 14.sp,
                  color: AppColor.lighterGreen,
                ),
              ),
              SizedBox(width: 6.w),
              AppText.small(
                label,
                color: Colors.grey[400],
              ),
            ],
          ),
          SizedBox(height: 6.h),
          AppText.medium(
            value,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}