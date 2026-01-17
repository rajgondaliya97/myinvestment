import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/view_model/user_plan_provoder.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../utils/app_color.dart';
import '../../../model/user_plan/user_plan_model.dart';
import '../../home/widget/custom_drawer.dart';

class UserActivePlansScreen extends StatefulWidget {
  const UserActivePlansScreen({Key? key}) : super(key: key);

  @override
  State<UserActivePlansScreen> createState() => _UserActivePlansScreenState();
}

class _UserActivePlansScreenState extends State<UserActivePlansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch plans on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserPlanController>().fetchUserPlans(refresh: true);
    });

    // Setup pagination listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final planController = context.read<UserPlanController>();
      if (planController.hasMoreData && !planController.isLoadingMore) {
        planController.loadMorePlans();
      }
    }
  }

  Future<void> _onRefresh() async {
    await context.read<UserPlanController>().fetchUserPlans(refresh: true);
  }

  String _formatCurrency(int? amount) {
    if (amount == null) return '\$0.00';
    return '\$${NumberFormat('#,##0.00').format(amount)}';
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return AppColor.lighterGreen;
      case 'completed':
        return Colors.blue;
      case 'expired':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondaryPrimaryColor,
      appBar: CustomAppBar(title: 'My Investment Plans'),
      drawer: CustomDrawer(currentRoute: 'active_plans'),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColor.screenGradientBgColor,
        ),
        child: Column(
          children: [
            // Summary Cards
            _buildSummarySection(),

            // Tab Bar
            _buildTabBar(),

            // Tab Bar View
            Expanded(
              child: Consumer<UserPlanController>(
                builder: (context, planController, child) {
                  if (planController.isLoading && planController.userPlans.isEmpty) {
                    return _buildLoadingState();
                  }

                  if (planController.errorMessage != null &&
                      planController.userPlans.isEmpty) {
                    return _buildErrorState(planController.errorMessage!);
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPlansList(planController.activePlans, planController),
                      _buildPlansList(planController.completedPlans, planController),
                    //  _buildPlansList(planController.expiredPlans, planController),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Consumer<UserPlanController>(
      builder: (context, planController, child) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Investment',
                  value: _formatCurrency(planController.totalInvestment.toInt()),
                  icon: Icons.account_balance_wallet,
                  gradient: [
                    AppColor.lighterGreen.withOpacity(0.8),
                    AppColor.primaryColor.withOpacity(0.6),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Returns',
                  value: _formatCurrency(planController.totalInterestEarned.toInt()),
                  icon: Icons.trending_up,
                  gradient: [
                    Colors.blue.withOpacity(0.8),
                    Colors.purple.withOpacity(0.6),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24.sp),
          SizedBox(height: 8.h),
          AppText.medium(
            title,
            fontSize: 12,
            color: Colors.white70,
          ),
          SizedBox(height: 4.h),
          AppText.medium(
            value,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.secondaryPrimaryColor.withOpacity(0.8),
            AppColor.primaryColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColor.lighterGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.lighterGreen,
              AppColor.primaryColor,
            ],
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[400],
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        padding: EdgeInsets.all(4.w),
        labelPadding: EdgeInsets.zero,
        tabs: [
          Tab(text: 'Active'),
          Tab(text: 'Completed'),
          //Tab(text: 'Expired'),
        ],
      ),
    );
  }

  Widget _buildPlansList(List<UserPlanModelData> plans, UserPlanController controller) {
    if (plans.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColor.lighterGreen,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(20.w),
        // Use AlwaysScrollableScrollPhysics to ensure RefreshIndicator works even with few items
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: plans.length + (controller.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == plans.length) {
            return _buildLoadingMoreIndicator();
          }
          return _buildPlanCard(plans[index]);
        },
      ),
    );
  }

  Widget _buildPlanCard(UserPlanModelData plan) {
    final daysRemaining = _calculateDaysRemaining(plan.endDate);
    final progress = _calculateProgress(plan.startDate, plan.endDate);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.secondaryPrimaryColor.withOpacity(0.9),
            AppColor.primaryColor.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColor.lighterGreen.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText.medium(
                  plan.planName ?? 'Investment Plan',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(plan.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: _getStatusColor(plan.status),
                    width: 1,
                  ),
                ),
                child: AppText.medium(
                  plan.status?.toUpperCase() ?? 'N/A',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(plan.status),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Investment Amount
          _buildInfoRow(
            icon: Icons.account_balance_wallet,
            label: 'Investment',
            value: _formatCurrency(plan.amount),
            valueColor: AppColor.lighterGreen,
          ),
          SizedBox(height: 12.h),

          // Daily Interest
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Daily Interest',
            value: _formatCurrency(plan.dailyInterest),
            valueColor: Colors.blue[300],
          ),
          SizedBox(height: 12.h),

          // Total Interest
          _buildInfoRow(
            icon: Icons.trending_up,
            label: 'Total Returns',
            value: _formatCurrency(plan.totalInterest),
            valueColor: Colors.green[300],
          ),
          SizedBox(height: 16.h),

          // Dates Row
          Row(
            children: [
              Expanded(
                child: _buildDateInfo(
                  label: 'Start Date',
                  date: _formatDate(plan.startDate),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildDateInfo(
                  label: 'End Date',
                  date: _formatDate(plan.endDate),
                ),
              ),
            ],
          ),

          // Progress Bar (only for active plans)
          if (plan.status?.toLowerCase() == 'active') ...[
            SizedBox(height: 16.h),
            _buildProgressBar(progress, daysRemaining),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor.lighterGreen.withOpacity(0.2),
                AppColor.primaryColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: AppColor.lighterGreen,
            size: 16.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: AppText.medium(
            label,
            fontSize: 13,
            color: Colors.grey[400],
          ),
        ),
        AppText.medium(
          value,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: valueColor ?? Colors.white,
        ),
      ],
    );
  }

  Widget _buildDateInfo({required String label, required String date}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor.withOpacity(0.2),
            AppColor.secondaryPrimaryColor.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColor.lighterGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            label,
            fontSize: 11,
            color: Colors.grey[400],
          ),
          SizedBox(height: 4.h),
          AppText.medium(
            date,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress, int daysRemaining) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText.medium(
              'Progress',
              fontSize: 12,
              color: Colors.grey[400],
            ),
            AppText.medium(
              '$daysRemaining days remaining',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.lighterGreen,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8.h,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(AppColor.lighterGreen),
          ),
        ),
        SizedBox(height: 4.h),
        AppText.medium(
          '${(progress * 100).toStringAsFixed(1)}% Complete',
          fontSize: 11,
          color: Colors.grey[500],
        ),
      ],
    );
  }

  int _calculateDaysRemaining(String? endDate) {
    if (endDate == null) return 0;
    try {
      final end = DateTime.parse(endDate);
      final now = DateTime.now();
      final difference = end.difference(now).inDays;
      return difference > 0 ? difference : 0;
    } catch (e) {
      return 0;
    }
  }

  double _calculateProgress(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return 0.0;
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      final now = DateTime.now();

      final totalDays = end.difference(start).inDays;
      final elapsedDays = now.difference(start).inDays;

      if (totalDays <= 0) return 0.0;
      final progress = elapsedDays / totalDays;
      return progress.clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColor.lighterGreen,
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          AppText.medium(
            'Loading your plans...',
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColor.lighterGreen,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80.sp,
            color: Colors.grey[600],
          ),
          SizedBox(height: 16.h),
          AppText.medium(
            'No plans found',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
          SizedBox(height: 8.h),
          AppText.medium(
            'Your plans will appear here',
            fontSize: 13,
            color: Colors.grey[500],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80.sp,
            color: Colors.red[400],
          ),
          SizedBox(height: 16.h),
          AppText.medium(
            'Oops! Something went wrong',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: AppText.medium(
              error,
              fontSize: 13,
              color: Colors.grey[500],
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.lighterGreen,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: AppText.medium(
              'Retry',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}