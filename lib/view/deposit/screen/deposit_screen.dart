import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_button.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../view_model/deposit_provider.dart';
import '../../../view_model/home_provider.dart';
import '../../home/widget/balance_card_widget.dart';
import '../../home/widget/custom_drawer.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({Key? key}) : super(key: key);

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _showBalance = false;
  String _selectedCurrency = 'USD';
  String _selectedTariff = 'basic';

  final Map<String, Map<String, dynamic>> _tariffs = {
    'basic': {
      'name': 'Basic',
      'rate': '1-1.5%',
      'days': 15,
      'minProfit': 0.27,
      'maxProfit': 0.40,
      'avgProfit': 0.33,
      'minAmount': 100,
      'maxAmount': 5000,
    },
    'advanced': {
      'name': 'Advanced',
      'rate': '1.5-2%',
      'days': 25,
      'minProfit': 0.35,
      'maxProfit': 0.50,
      'avgProfit': 0.42,
      'minAmount': 1000,
      'maxAmount': 10000,
    },
    'professional': {
      'name': 'Professional',
      'rate': '2-3%',
      'days': 30,
      'minProfit': 0.45,
      'maxProfit': 0.65,
      'avgProfit': 0.55,
      'minAmount': 5000,
      'maxAmount': 50000,
    },
  };

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: Color(0xFF00FF00), width: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: Color(0xFF00FF00).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Color(0xFF00FF00),
                size: 50.sp,
              ),
            ),
            SizedBox(height: 20.h),
            AppText.large(
              'Success!',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF00FF00),
            ),
            SizedBox(height: 12.h),
            AppText.medium(
              'You have successfully created new deposit',
              fontSize: 14,
              textAlign: TextAlign.center,
              color: Colors.grey[400],
            ),
          ],
        ),
        actions: [
          Center(
            child: AppButton.primary(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              text: 'Done',
              width: 120,
              height: 45,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final depositProvider = Provider.of<DepositProvider>(context);
    final selectedTariffData = _tariffs[_selectedTariff]!;
    final homeProvider = Provider.of<HomeProvider>(context);
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar:
      CustomAppBar(
        title: 'Create Deposit',
      ),
      drawer: CustomDrawer(
        currentRoute: 'home',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Balance Card
            BalanceCard(
              balance: homeProvider.balance,
              profitPercentage: homeProvider.profitPercentage,
            ),
            SizedBox(height: 20.h),

            // Choose Balance
            _buildChooseBalanceCard(depositProvider),
            SizedBox(height: 20.h),

            // Tariff Selection
            _buildTariffCard(),
            SizedBox(height: 20.h),

            // Deposit Amount
            _buildDepositAmountCard(selectedTariffData),
            SizedBox(height: 20.h),

            // Profit Per Day
            _buildProfitPerDayCard(selectedTariffData),
            SizedBox(height: 20.h),

            // Profit By Period
            _buildProfitByPeriodCard(selectedTariffData),
            SizedBox(height: 20.h),

            // Plan Details
            _buildPlanDetailsCard(selectedTariffData),
            SizedBox(height: 30.h),

            // Create Deposit Button
            AppButton.primary(
              onPressed: () {
                final amount = double.tryParse(_amountController.text);
                if (amount != null &&
                    amount >= selectedTariffData['minAmount'] &&
                    amount <= selectedTariffData['maxAmount']) {
                  _showSuccessDialog();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid amount'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              text: 'Create Deposit',
              width: double.infinity,
              height: 55,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(DepositProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF00FF00).withOpacity(0.15),
            Color(0xFF00CC00).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Color(0xFF00FF00).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.medium(
                'BALANCE',
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showBalance = !_showBalance;
                  });
                },
                child: Row(
                  children: [
                    AppText.medium(
                      _showBalance ? 'HIDE' : 'SHOW',
                      fontSize: 12,
                      color: Color(0xFF00FF00),
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      _showBalance ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Color(0xFF00FF00),
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AppText.medium(
            'TOTAL AMOUNT',
            fontSize: 11,
            color: Colors.grey[600],
          ),
          SizedBox(height: 8.h),
          AppText.large(
            _showBalance ? '${provider.totalBalance.toStringAsFixed(2)} USD' : '••••••',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF00FF00),
          ),
        ],
      ),
    );
  }

  Widget _buildChooseBalanceCard(DepositProvider provider) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Color(0xFF2A2A2A),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            'CHOOSE BALANCE',
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 16.h),
          _buildBalanceOption('USD', provider.usdBalance, Icons.attach_money, true),
          SizedBox(height: 12.h),
          _buildBalanceOption('BITCOIN', provider.btcBalance, Icons.currency_bitcoin, false),
          SizedBox(height: 12.h),
          _buildBalanceOption('ETHEREUM', provider.ethBalance, Icons.currency_exchange, false),
        ],
      ),
    );
  }

  Widget _buildBalanceOption(String currency, double balance, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCurrency = currency;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF00FF00).withOpacity(0.15) : Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Color(0xFF00FF00) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF00FF00) : Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.black : Colors.grey[600],
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.medium(
                    currency,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Color(0xFF00FF00) : Colors.grey[400],
                  ),
                  SizedBox(height: 4.h),
                  AppText.medium(
                    balance.toStringAsFixed(currency == 'USD' ? 2 : 8),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTariffCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Color(0xFF2A2A2A),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            'TARIFF',
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 16.h),
          _buildTariffOption('basic', 'Basic', '1-1.5% / 15 days'),
          SizedBox(height: 12.h),
          _buildTariffOption('advanced', 'Advanced', '1.5-2% / 25 days'),
          SizedBox(height: 12.h),
          _buildTariffOption('professional', 'Professional', '2-3% / 30 days'),
        ],
      ),
    );
  }

  Widget _buildTariffOption(String key, String title, String subtitle) {
    bool isSelected = _selectedTariff == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTariff = key;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF00FF00).withOpacity(0.15) : Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Color(0xFF00FF00) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.medium(
                  title,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Color(0xFF00FF00) : Colors.white,
                ),
                SizedBox(height: 4.h),
                AppText.medium(
                  subtitle,
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ],
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Color(0xFF00FF00) : Colors.grey[600],
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepositAmountCard(Map<String, dynamic> tariffData) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Color(0xFF2A2A2A),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            'DEPOSIT AMOUNT',
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Color(0xFF00FF00).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '1000',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                ),
                AppText.medium(
                  'USD',
                  fontSize: 16,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.medium(
                'MIN AMOUNT: ',
                fontSize: 13,
                color: Colors.grey[600],
              ),
              AppText.medium(
                '${tariffData['minAmount']}',
                fontSize: 13,
                color: Color(0xFF00FF00),
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.medium(
                'MAX AMOUNT: ',
                fontSize: 13,
                color: Colors.grey[600],
              ),
              AppText.medium(
                '${tariffData['maxAmount']}',
                fontSize: 13,
                color: Color(0xFF00FF00),
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfitPerDayCard(Map<String, dynamic> tariffData) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF00FF00).withOpacity(0.2),
            Color(0xFF00CC00).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Color(0xFF00FF00).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            'PROFIT PER DAY',
            fontSize: 12,
            color: Colors.grey[400],
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildProfitMetric(
                  'MINIMUM PROFIT',
                  '${tariffData['minProfit']} USD',
                  Icons.trending_down,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildProfitMetric(
                  'MAXIMUM PROFIT',
                  '${tariffData['maxProfit']} USD',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Color(0xFF00FF00),
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.medium(
                      'AVERAGE PROFIT',
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                    SizedBox(height: 4.h),
                    AppText.large(
                      '${tariffData['avgProfit']} USD',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00FF00),
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

  Widget _buildProfitMetric(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Color(0xFF00FF00),
            size: 20.sp,
          ),
          SizedBox(height: 8.h),
          AppText.medium(
            label,
            fontSize: 10,
            color: Colors.grey[500],
          ),
          SizedBox(height: 4.h),
          AppText.medium(
            value,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildProfitByPeriodCard(Map<String, dynamic> tariffData) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final weeklyProfit = (amount * tariffData['avgProfit']) * 7;
    final totalProfit = (amount * tariffData['avgProfit']) * tariffData['days'];

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Color(0xFF2A2A2A),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            'PROFIT BY PERIOD',
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00FF00),
                  Color(0xFF00CC00),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                AppText.large(
                  weeklyProfit.toStringAsFixed(2),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                SizedBox(height: 4.h),
                AppText.medium(
                  'USD',
                  fontSize: 12,
                  color: Colors.black87,
                ),
                SizedBox(height: 8.h),
                AppText.medium(
                  'Weekly profit',
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                AppText.large(
                  totalProfit.toStringAsFixed(2),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00FF00),
                ),
                SizedBox(height: 4.h),
                AppText.medium(
                  'USD',
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                SizedBox(height: 8.h),
                AppText.medium(
                  'Total profit',
                  fontSize: 13,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDetailsCard(Map<String, dynamic> tariffData) {
    final now = DateTime.now();
    final expiryDate = now.add(Duration(days: tariffData['days']));

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Color(0xFF2A2A2A),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            'PLAN DETAILS',
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 16.h),
          _buildDetailRow('Open date', _formatDate(now)),
          SizedBox(height: 12.h),
          _buildDetailRow('Expire date', _formatDate(expiryDate)),
          SizedBox(height: 12.h),
          _buildDetailRow('Accrual of profit', 'Monday - Friday'),
          SizedBox(height: 12.h),
          _buildDetailRow('Withdrawal of funds', 'Monday - Friday'),
          SizedBox(height: 12.h),
          _buildDetailRow('Deposit term', '${tariffData['days']} days'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.medium(
          label,
          fontSize: 13,
          color: Colors.grey[500],
        ),
        AppText.medium(
          value,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
  }
}