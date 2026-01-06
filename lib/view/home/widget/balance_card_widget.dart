import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/utils/app_color.dart';

import '../../../res/app_widget/custom_app_text.dart';

class BalanceCard extends StatefulWidget {
  final double balance;
  final double profitPercentage;
  final double usdBalance;
  final double bitcoinBalance;
  final double ethereumBalance;
  final double pointsBalance;

  const BalanceCard({
    Key? key,
    required this.balance,
    required this.profitPercentage,
    this.usdBalance = 0,
    this.bitcoinBalance = 0,
    this.ethereumBalance = 0,
    this.pointsBalance = 0,
  }) : super(key: key);

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.secondaryPrimaryColor.withOpacity(0.8),
            AppColor.primaryColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Color(0xFF00FF00).withOpacity(0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Balance Section
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.medium(
                      'Total Balance',
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                    GestureDetector(
                      onTap: _toggleExpanded,
                      child: Row(
                        children: [
                          AppText.small(
                            _isExpanded ? 'HIDE' : 'SHOW',
                            color: Color(0xFF00FF00),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          SizedBox(width: 4.w),
                          AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: Duration(milliseconds: 300),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF00FF00),
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                AppText.large(
                  '\$${widget.balance.toStringAsFixed(2)}',
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 25,
                ),
                SizedBox(height: 8.h),
                AppText.small(
                  fontSize: 10,
                  'Available for withdrawal',
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),

          // Expandable Detailed Balance Section
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A).withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
              ),
              child: Column(
                children: [
                  // Total Amount Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.medium(
                        'TOTAL AMOUNT',
                        color: Colors.grey[500],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      AppText.medium(
                        '${widget.balance.toStringAsFixed(0)} USD',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Currency Balances
                  _buildCurrencyItem(
                    'US DOLLAR',
                    widget.balance,
                    Icons.attach_money,
                    Color(0xFF00FF00),
                  ),
                  SizedBox(height: 12.h),

                  _buildCurrencyItem(
                    'BITCOIN',
                    widget.bitcoinBalance,
                    Icons.currency_bitcoin,
                    Color(0xFFF7931A),
                  ),
                  SizedBox(height: 12.h),

                  _buildCurrencyItem(
                    'ETHEREUM',
                    widget.ethereumBalance,
                    Icons.diamond,
                    Color(0xFF627EEA),
                  ),
                  SizedBox(height: 5.h),

                  // Action Buttons
                  /*Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'REFILL',
                              () {
                            // Handle refill
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildActionButton(
                          'WITHDRAW',
                              () {
                            // Handle withdraw
                          },
                        ),
                      ),
                    ],
                  ),*/
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem(String name, double amount, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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
              color: Color(0xFF000000).withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.small(
                name,
                color: Colors.grey[400],
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 2.h),
              AppText.medium(
                amount.toStringAsFixed(0),
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsItem(String name, double amount) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Color(0xFF00FF00).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Color(0xFF00FF00).withOpacity(0.4),
          width: 1.5.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Color(0xFF000000).withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: AppText.medium(
                'BBT',
                color: Color(0xFF00FF00),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.small(
                name,
                color: Colors.grey[400],
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 2.h),
              AppText.medium(
                amount.toStringAsFixed(0),
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: Color(0xFF00FF00).withOpacity(0.3),
            width: 1.w,
          ),
        ),
        child: Center(
          child: AppText.medium(
            text,
            color: Color(0xFF00FF00),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}