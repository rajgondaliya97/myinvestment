import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/utils/app_color.dart';
import 'package:provider/provider.dart';

import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../utils/app_constent.dart';
import '../../../view_model/auth_provider.dart';
import '../../../view_model/home_provider.dart';
import '../../wallte/screen/add_waller_screen.dart';
import '../../wallte/screen/withdraw_amount_screen.dart';
import '../widget/balance_card_widget.dart';
import '../widget/calculator_card.dart';
import '../widget/profit_chart_card.dart';
import '../widget/custom_drawer.dart';
import 'investment_calculator_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Theme colors
  static const Color primaryBlue = Color(0xFF031c40);

  @override
  void initState() {
    super.initState();
    // Load user data and fetch dashboard data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);

      // Load user from storage
      authController.loadUserFromStorage();

      // Fetch dashboard data from API
      homeProvider.fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final homeProvider = Provider.of<HomeProvider>(context);

    // Get user data from model
    final userName =
        authController.user?.user?.name ??
        '${authController.user?.user?.firstName ?? ''} ${authController.user?.user?.lastName ?? ''}'
            .trim();
    final userEmail = authController.user?.user?.email ?? 'user@example.com';
    final profileImage = '';

    return Scaffold(
      backgroundColor: AppColor.secondaryPrimaryColor,
      appBar: CustomAppBar(
        title: AppConst.appName,
        profileImageUrl: profileImage,
      ),
      drawer: CustomDrawer(currentRoute: 'home'),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColor.screenGradientBgColor,
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh user data and dashboard data
            await authController.loadUserFromStorage();
            await homeProvider.refreshData();
          },
          color: AppColor.primaryColor,
          backgroundColor: AppColor.secondaryPrimaryColor,
          child: homeProvider.isLoading && homeProvider.dashboardData == null
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColor.primaryColor,
                    ),
                  ),
                )
              : homeProvider.errorMessage != null &&
                    homeProvider.dashboardData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60.sp,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      AppText.medium(
                        'Failed to load dashboard',
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 8.h),
                      AppText.small(
                        homeProvider.errorMessage ?? 'Unknown error',
                        color: Colors.grey[500],
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColor.secondaryPrimaryColor,
                              AppColor.primaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ElevatedButton(
                          onPressed: () => homeProvider.fetchDashboardData(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32.w,
                              vertical: 12.h,
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
                )
              : SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome message with user name
                      AppText.medium(
                        'Welcome back,',
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      SizedBox(height: 4.h),
                      AppText.large(
                        userName.isNotEmpty ? userName : 'User',
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: 4.h),
                      // User email
                      AppText.small(
                        userEmail,
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                      SizedBox(height: 24.h),

                      // Balance Card with API data
                      BalanceCard(
                        balance: homeProvider.balance,
                        profitPercentage: homeProvider.profitPercentage,
                      ),
                      SizedBox(height: 20.h),

                      // Dashboard Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.account_balance_wallet,
                              label: 'Active Plans',
                              value: '${homeProvider.activePlans}',
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.check_circle,
                              label: 'Approved',
                              value: '${homeProvider.totalWithdrawalsApprove}',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.receipt_long,
                              label: 'Total Withdrawals',
                              value: '${homeProvider.totalWithdrawals}',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      CalculatorCard(
                        onCalculatorTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  InvestmentCalculatorScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20.h),
                      // Profit Chart Card
                      ProfitChartCard(
                        chartData: homeProvider.currentChartData,
                        selectedPeriod: homeProvider.selectedPeriod,
                        onPeriodSelected: (period) =>
                            homeProvider.selectPeriod(period),
                        isLoading: homeProvider.isLoading,
                      ),
                      SizedBox(height: 20.h),

                      // Quick Actions
                      Row(
                        children: [
                          Expanded(
                            child: AppButton.primary(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AddWalletScreen(),));
                              },
                              text: 'Deposit',
                              icon: Icons.add,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: AppButton.primary(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => WithdrawAmountScreen(),));
                              },
                              text: 'Withdraw',
                              icon: Icons.remove,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primaryColor.withOpacity(0.3),
                      AppColor.secondaryPrimaryColor.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: AppColor.primaryColor, size: 20.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AppText.small(label, color: Colors.grey[400], fontSize: 11),
          SizedBox(height: 4.h),
          AppText.large(
            value,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
