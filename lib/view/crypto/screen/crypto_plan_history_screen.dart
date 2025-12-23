// crypto_plan_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/res/app_widget/custom_app_bar.dart';
import 'package:provider/provider.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../view_model/investment_controller.dart';
import '../../home/widget/custom_drawer.dart';

class CryptoPlanHistoryScreen extends StatefulWidget {
  const CryptoPlanHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CryptoPlanHistoryScreen> createState() => _CryptoPlanHistoryScreenState();
}

class _CryptoPlanHistoryScreenState extends State<CryptoPlanHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch crypto plans when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvestmentProvider>(context, listen: false).fetchCryptoPlans();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Color(0xFF00FF00);
      case 'completed':
        return Color(0xFF00BFFF);
      case 'pending':
        return Color(0xFFFFA500);
      case 'cancelled':
        return Color(0xFFFF4444);
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
      backgroundColor: Color(0xFF0A0A0A),
      appBar: CustomAppBar(
        title: 'Crypto Plans History',
      ),
      drawer: CustomDrawer(currentRoute: 'crypto'),
      body: Consumer<InvestmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF00)),
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(height: 16.h),
                  AppText.medium(
                    provider.errorMessage!,
                    color: Colors.grey[400],
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () => provider.fetchCryptoPlans(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00FF00),
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: AppText.medium(
                      'Retry',
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.cryptoPlans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xFF00FF00).withOpacity(0.3),
                        width: 2.w,
                      ),
                    ),
                    child: Icon(
                      Icons.currency_bitcoin,
                      size: 60.sp,
                      color: Color(0xFF00FF00).withOpacity(0.5),
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
                    color: Colors.grey[500],
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: Color(0xFF00FF00),
            backgroundColor: Color(0xFF1A1A1A),
            onRefresh: () => provider.fetchCryptoPlans(),
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: provider.cryptoPlans.length,
              itemBuilder: (context, index) {
                final plan = provider.cryptoPlans[index];
                final status = plan['status'] ?? 'Pending';
                final statusColor = _getStatusColor(status);

                return Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Color(0xFF2A2A2A),
                      width: 1.5.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF00FF00).withOpacity(0.05),
                        blurRadius: 20,
                        offset: Offset(0, 4),
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
                              Color(0xFF00FF00).withOpacity(0.15),
                              Color(0xFF00FF00).withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
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
                                    Color(0xFF00FF00),
                                    Color(0xFF00CC00),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF00FF00).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getCoinIcon(plan['coinSymbol'] ?? ''),
                                color: Colors.black,
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
                                    plan['coinName'] ?? 'Unknown',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  SizedBox(height: 4.h),
                                  AppText.small(
                                    fontSize: 10,
                                    plan['coinSymbol'] ?? '',
                                    color: Color(0xFF00FF00),
                                    fontWeight: FontWeight.w600,
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
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.5),
                                  width: 1.w,
                                ),
                              ),
                              child: AppText.small(
                                status,
                                fontSize: 10,
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
                                color: Color(0xFF0A0A0A),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: Color(0xFF2A2A2A),
                                  width: 1.w,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  AppText.small(
                                    fontSize: 10,
                                    'Investment Amount',
                                    color: Colors.grey[500],
                                  ),
                                  AppText.medium(
                                    '\$${plan['amount']?.toStringAsFixed(2) ?? '0.00'}',
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF00FF00),
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
                                    value: plan['startDate'] ?? 'N/A',
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _buildInfoCard(
                                    icon: Icons.event,
                                    label: 'End Date',
                                    value: plan['endDate'] ?? 'N/A',
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
              },
            ),
          );
        },
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
        color: Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Color(0xFF2A2A2A),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14.sp,
                color: Color(0xFF00FF00),
              ),
              SizedBox(width: 6.w),
              AppText.small(
                label,
                color: Colors.grey[500],
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