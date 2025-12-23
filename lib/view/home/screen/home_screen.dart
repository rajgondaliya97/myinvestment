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
import '../widget/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load user data from local storage when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(context, listen: false);
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);

      authController.loadUserFromStorage();

      // Initialize home provider with user's wallet data
      if (authController.user != null) {
        homeProvider.initializeWithUserData(
          walletBalance: authController.user?.user?.walletBalance,
          investmentAmount: authController.user?.user?.investmentAmount,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final homeProvider = Provider.of<HomeProvider>(context);

    // Get user data from model
    final userName = authController.user?.user?.name ??
        '${authController.user?.user?.firstName ?? ''} ${authController.user?.user?.lastName ?? ''}'.trim();
    final userEmail = authController.user?.user?.email ?? 'user@example.com';
    final profileImage = '';

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Investment App',
        profileImageUrl: profileImage,
        onProfileTap: () {
          // Navigate to profile screen
        },
      ),
      drawer: CustomDrawer(
        currentRoute: 'home',
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh user data from storage
          await authController.loadUserFromStorage();
          //    await homeProvider.refreshData();
        },
        color: Color(0xFF00FF00),
        child: SingleChildScrollView(
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