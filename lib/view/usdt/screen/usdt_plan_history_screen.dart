import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/utils/app_color.dart';
import 'package:provider/provider.dart';
import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../view_model/investment_controller.dart';
import '../../home/widget/custom_drawer.dart';

class UsdtPlanHistoryScreen extends StatefulWidget {
  const UsdtPlanHistoryScreen({Key? key}) : super(key: key);

  @override
  State<UsdtPlanHistoryScreen> createState() => _UsdtPlanHistoryScreenState();
}

class _UsdtPlanHistoryScreenState extends State<UsdtPlanHistoryScreen> {

  @override
  void initState() {
    super.initState();
    // Fetch USDT plans when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvestmentProvider>(context, listen: false).fetchUsdtPlans();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondaryPrimaryColor,
      appBar: CustomAppBar(
        title: 'USDT Plans History',
      ),
      drawer: CustomDrawer(currentRoute: 'usdt'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.secondaryPrimaryColor,
              Color(0xFF021530),
              AppColor.primaryColor.withOpacity(0.3),
            ],
          ),
        ),
        child: Consumer<InvestmentProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.lighterGreen),
                ),
              );
            }

            if (provider.errorMessage != null) {
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
                        onPressed: () => provider.fetchUsdtPlans(),
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

            if (provider.usdtPlans.isEmpty) {
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
                        Icons.account_balance_wallet,
                        size: 60.sp,
                        color: AppColor.lighterGreen.withOpacity(0.6),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    AppText.large(
                      'No USDT Plans Yet',
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: 8.h),
                    AppText.medium(
                      'Your USDT stablecoin investment\nhistory will appear here',
                      color: Colors.grey[400],
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppColor.lighterGreen,
              backgroundColor: AppColor.lighterBlue,
              onRefresh: () => provider.fetchUsdtPlans(),
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: provider.usdtPlans.length,
                itemBuilder: (context, index) {
                  final plan = provider.usdtPlans[index];
                  final status = plan['status'] ?? 'Pending';
                  final statusColor = _getStatusColor(status);

                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColor.lighterBlue.withOpacity(0.8),
                          AppColor.secondaryPrimaryColor.withOpacity(0.9),
                          AppColor.primaryColor.withOpacity(0.1),
                        ],
                      ),
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
                        // Header with USDT info
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
                              // USDT Icon
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
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              // Plan Name
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText.medium(
                                      plan['planName'] ?? 'USDT Plan',
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
                                        'Stablecoin Investment',
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
                                            '${plan['amount']?.toStringAsFixed(2) ?? '0.00'}',
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

                              // Additional Info (if available)
                              if (plan['interestRate'] != null) ...[
                                SizedBox(height: 12.h),
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColor.secondaryPrimaryColor.withOpacity(0.8),
                                        AppColor.primaryColor.withOpacity(0.2),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: AppColor.lighterGreen.withOpacity(0.3),
                                      width: 1.w,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(6.w),
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
                                              Icons.trending_up,
                                              size: 16.sp,
                                              color: AppColor.lighterGreen,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          AppText.medium(
                                            fontSize: 12,
                                            'Interest Rate',
                                            color: Colors.grey[300],
                                          ),
                                        ],
                                      ),
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: [AppColor.lighterGreen, AppColor.primaryColor],
                                        ).createShader(bounds),
                                        child: AppText.medium(
                                          '${plan['interestRate']}%',
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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