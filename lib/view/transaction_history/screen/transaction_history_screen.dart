import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../model/transaction_model/transaction_history_model.dart';
import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../utils/app_color.dart';
import '../../../view_model/transaction_controller.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    print('🚀 TransactionHistoryScreen initState called');

    // Fetch transactions on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🚀 PostFrameCallback - Attempting to fetch transactions');
      try {
        final controller = context.read<TransactionController>();
        print('🚀 Controller found: ${controller != null}');
        controller.fetchTransactionHistory(refresh: true);
      } catch (e) {
        print('❌ Error in PostFrameCallback: $e');
      }
    });

    // Setup pagination listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final transactionController = context.read<TransactionController>();
      if (transactionController.hasMoreData && !transactionController.isLoadingMore) {
        transactionController.loadMoreTransactions();
      }
    }
  }

  Future<void> _onRefresh() async {
    await context.read<TransactionController>().fetchTransactionHistory(refresh: true);
  }

  void _onSearch(String query) {
    context.read<TransactionController>().searchTransactions(query);
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: AppColor.cardGradientBgColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            AppText.medium(
              'Sort Transactions',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            SizedBox(height: 20.h),
            _buildSortOption('Newest First', 'desc'),
            SizedBox(height: 12.h),
            _buildSortOption('Oldest First', 'asc'),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, String sortOrder) {
    final transactionController = context.read<TransactionController>();
    final isSelected = transactionController.sortOrder == sortOrder;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        transactionController.changeSortOrder(sortOrder);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [
              AppColor.lighterGreen,
              AppColor.primaryColor,
            ]
                : [
              AppColor.secondaryPrimaryColor.withOpacity(0.8),
              AppColor.primaryColor.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColor.lighterGreen
                : AppColor.lighterGreen.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            AppText.medium(
              title,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(String? amount) {
    if (amount == null) return '\$0.00';
    final numAmount = double.tryParse(amount) ?? 0.0;
    return '\$${NumberFormat('#,##0.00').format(numAmount)}';
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'credit':
        return AppColor.lighterGreen;
      case 'debit':
        return Colors.red[400]!;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'credit':
        return Icons.arrow_downward;
      case 'debit':
        return Icons.arrow_upward;
      default:
        return Icons.sync;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondaryPrimaryColor,
      appBar: CustomAppBar(
        title: 'Transaction History',
        actions: [
          IconButton(
            icon: Icon(Icons.sort, color: Colors.white),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColor.screenGradientBgColor,
        ),
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(),

            // Summary Cards
            _buildSummarySection(),

            // Tab Bar
            _buildTabBar(),

            // Tab Bar View
            Expanded(
              child: Consumer<TransactionController>(
                builder: (context, transactionController, child) {
                  if (transactionController.isLoading &&
                      transactionController.transactions.isEmpty) {
                    return _buildLoadingState();
                  }

                  if (transactionController.errorMessage != null &&
                      transactionController.transactions.isEmpty) {
                    return _buildErrorState(transactionController.errorMessage!);
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // All Transactions
                      _buildTransactionsList(
                        transactionController.transactions,
                        transactionController,
                      ),
                      // Credit Transactions
                      _buildTransactionsList(
                        transactionController.creditTransactions,
                        transactionController,
                      ),
                      // Debit Transactions
                      _buildTransactionsList(
                        transactionController.debitTransactions,
                        transactionController,
                      ),
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

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColor.glassGradient,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColor.primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearch,
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: 'Search transactions...',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.7),
              size: 20.sp,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
              onPressed: () {
                _searchController.clear();
                _onSearch('');
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Consumer<TransactionController>(
      builder: (context, transactionController, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Credit',
                  value: _formatCurrency(
                      transactionController.totalCreditAmount.toString()),
                  icon: Icons.arrow_downward,
                  gradient: [
                    AppColor.lighterGreen.withOpacity(0.8),
                    AppColor.primaryColor.withOpacity(0.6),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Debit',
                  value: _formatCurrency(
                      transactionController.totalDebitAmount.toString()),
                  icon: Icons.arrow_upward,
                  gradient: [
                    Colors.red.withOpacity(0.8),
                    Colors.orange.withOpacity(0.6),
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
          Icon(icon, color: Colors.white, size: 20.sp),
          SizedBox(height: 8.h),
          AppText.medium(
            title,
            fontSize: 11,
            color: Colors.white70,
          ),
          SizedBox(height: 4.h),
          AppText.medium(
            value,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
        padding: EdgeInsets.all(4.w),
        labelPadding: EdgeInsets.zero,
        tabs: [
          Tab(text: 'All'),
          Tab(text: 'Credit'),
          Tab(text: 'Debit'),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
      List<TransactionHistoryModelData> transactions,
      TransactionController controller) {
    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColor.lighterGreen,
      backgroundColor: AppColor.secondaryPrimaryColor,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        itemCount: transactions.length + (controller.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == transactions.length) {
            return _buildLoadingMoreIndicator();
          }
          return _buildTransactionCard(transactions[index]);
        },
      ),
    );
  }

  Widget _buildTransactionCard(TransactionHistoryModelData transaction) {
    final isCredit = transaction.type?.toLowerCase() == 'credit';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
          color: _getTypeColor(transaction.type).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: _getTypeColor(transaction.type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getTypeIcon(transaction.type),
                  color: _getTypeColor(transaction.type),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              // Transaction Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.medium(
                      transaction.category ?? 'Transaction',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    SizedBox(height: 4.h),
                    AppText.medium(
                      _formatDate(transaction.createdAt),
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
              // Amount
              AppText.medium(
                '${isCredit ? '+' : '-'}${_formatCurrency(transaction.amount)}',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getTypeColor(transaction.type),
              ),
            ],
          ),

          if (transaction.description != null &&
              transaction.description!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: AppText.medium(
                transaction.description!,
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],

          SizedBox(height: 12.h),
          // Footer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Transaction Reference
              Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: Colors.grey[600],
                    size: 14.sp,
                  ),
                  SizedBox(width: 6.w),
                  AppText.medium(
                    transaction.transactionReference ?? 'N/A',
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ],
              ),
              // Balance After
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColor.lighterGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColor.lighterGreen.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: AppText.medium(
                  'Balance: ${_formatCurrency(transaction.balanceAfter)}',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColor.lighterGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
            'Loading transactions...',
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
            Icons.receipt_long_outlined,
            size: 80.sp,
            color: Colors.grey[600],
          ),
          SizedBox(height: 16.h),
          AppText.medium(
            'No transactions found',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
          SizedBox(height: 8.h),
          AppText.medium(
            'Your transactions will appear here',
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