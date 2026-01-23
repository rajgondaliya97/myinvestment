import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/utils/app_color.dart';
import 'package:myinvestment/res/services/ReownWalletService.dart';  // ✅ Correct import
import 'package:myinvestment/res/services/MetaMaskConnectScreen.dart';
import 'package:myinvestment/view/deposit/screen/deposit_screen.dart';
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
import '../widget/connect_wallet_card.dart';
import '../widget/custom_drawer.dart';
import 'investment_calculator_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    // Initialize all services when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeServices();
    });
  }

  Future<void> _initializeServices() async {
    final authController = Provider.of<AuthController>(
      context,
      listen: false,
    );
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final walletService = Provider.of<ReownWalletService>(context, listen: false);

    // Initialize wallet service first
    try {
      await walletService.initialize();
      debugPrint('✅ [HomeScreen] Wallet service initialized');
    } catch (e) {
      debugPrint('❌ [HomeScreen] Wallet initialization error: $e');
    }

    // Load user from storage and fetch profile
    authController.loadUserFromStorage();
    authController.fetchUserProfile();

    // Fetch dashboard data from API
    homeProvider.fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    final walletService = Provider.of<ReownWalletService>(context);

    // Get user data from profileData (API) instead of local storage
    final userName = authController.profileData != null
        ? '${authController.profileData!.firstName ?? ''} ${authController.profileData!.lastName ?? ''}'
        .trim()
        : authController.user?.user?.name ?? 'User';

    final userEmail =
        authController.profileData?.email ??
            authController.user?.user?.email ??
            'user@example.com';

    // Check if initial loading is happening
    final isInitialLoading = (homeProvider.isLoading && homeProvider.dashboardData == null) ||
        (authController.isLoading && authController.profileData == null);

    return Scaffold(
      backgroundColor: AppColor.secondaryPrimaryColor,
      appBar: CustomAppBar(title: AppConst.appName),
      drawer: CustomDrawer(currentRoute: 'home'),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppColor.screenGradientBgColor),
        child: RefreshIndicator(
          onRefresh: () async {
            await authController.fetchUserProfile();
            await homeProvider.refreshData();
          },
          color: AppColor.primaryColor,
          backgroundColor: AppColor.secondaryPrimaryColor,
          child: isInitialLoading
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
                    onPressed: () {
                      homeProvider.fetchDashboardData();
                      authController.fetchUserProfile();
                    },
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
                // Welcome message with user name from API
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

                SizedBox(height: 16.h),

                // 🔥 WALLET CONNECTION CHECK CARD
                // Provider will automatically rebuild when walletService.isConnected changes
                if (!walletService.isConnected)
                  ConnectWalletCard(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MetaMaskConnectScreen(),
                        ),
                      );
                      // After returning from wallet import, the provider will auto-update the UI
                    },
                  )
                else
                  BalanceCard(),
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
                    /*SizedBox(width: 12.w),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.receipt_long,
                        label: 'Withdrawals',
                        value: '${homeProvider.totalWithdrawals}',
                      ),
                    ),*/
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.receipt_long,
                        label: 'Withdrawals',
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

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: AppButton.primary(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DepositScreen(showDrawerIcon: false,),
                            ),
                          );
                        },
                        text: 'Deposit',
                        icon: Icons.add,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppButton.primary(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WithdrawAmountScreen(),
                            ),
                          );
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
                child: Icon(icon, color: AppColor.primaryColor, size: 12.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AppText.small(label, color: Colors.grey[400], fontSize: 10,fontWeight: FontWeight.w800,),
          SizedBox(height: 4.h),
          AppText.medium(
            value,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}