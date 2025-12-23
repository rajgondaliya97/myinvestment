import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../view_model/auth_provider.dart';
import '../../../view_model/home_provider.dart';
import '../widget/balance_card_widget.dart';
import '../widget/profit_chart_card.dart';
import '../widget/custom_drawer.dart'; // Add this import

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Investment App',
        profileImageUrl: authProvider.user?['profileImage'],
        onProfileTap: () {
          // Navigate to profile screen
        },
      ),
      // Add this drawer property
      drawer: CustomDrawer(
        currentRoute: 'home',
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          //    await homeProvider.refreshData();
        },
        color: Color(0xFF00FF00),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              AppText.medium(
                'Welcome back,',
                color: Colors.grey[400],
                fontSize: 14,
              ),
              SizedBox(height: 4.h),
              AppText.large(
                authProvider.user?['name'] ?? 'User',
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: 24.h),

              // Balance Card
              BalanceCard(
                balance: homeProvider.balance,
                profitPercentage: homeProvider.profitPercentage,
              ),
              SizedBox(height: 20.h),

              // Profit Chart Card
              ProfitChartCard(
                chartData: homeProvider.currentChartData,
                selectedPeriod: homeProvider.selectedPeriod,
                onPeriodSelected: (period) => homeProvider.selectPeriod(period),
                isLoading: homeProvider.isLoading,
              ),
              SizedBox(height: 20.h),

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: AppButton.primary(
                      onPressed: () {},
                      text: 'Deposit',
                      icon: Icons.add,
                      height: 50,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppButton.outlined(
                      onPressed: () {},
                      text: 'Withdraw',
                      icon: Icons.remove,
                      height: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}