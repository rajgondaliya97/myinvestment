import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/res/app_widget/custom_app_button.dart';
import 'package:provider/provider.dart';
import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../utils/app_color.dart';
import '../../../view_model/pan_provider.dart';

class InvestmentCalculatorScreen extends StatefulWidget {
  const InvestmentCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<InvestmentCalculatorScreen> createState() =>
      _InvestmentCalculatorScreenState();
}

class _InvestmentCalculatorScreenState
    extends State<InvestmentCalculatorScreen> {
  int? selectedPlanId;
  double investmentAmount = 100;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlanProvider>(context, listen: false).fetchPlans();
    });
  }

  Map<String, dynamic> calculateProfit(
    double amount,
    String dailyRoi,
    int duration,
  ) {
    final dailyProfit = (amount * double.parse(dailyRoi)) / 100;
    final totalProfit = dailyProfit * duration;
    final totalReturn = amount + totalProfit;

    return {
      'dailyProfit': dailyProfit.toStringAsFixed(2),
      'totalProfit': totalProfit.toStringAsFixed(2),
      'totalReturn': totalReturn.toStringAsFixed(2),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: CustomAppBar(title: 'Investment Calculator',showDrawer: false,),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.secondaryPrimaryColor,
              AppColor.primaryColor.withOpacity(0.3),
              AppColor.secondaryPrimaryColor,
            ],
          ),
        ),
        child: Consumer<PlanProvider>(
          builder: (context, planProvider, child) {
            if (planProvider.isLoading && (planProvider.plans?.isEmpty ?? true)) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColor.primaryColor,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20.h),
                    AppText.medium('Loading plans...', color: Colors.white60),
                  ],
                ),
              );
            }

            if (planProvider.errorMessage != null &&
                planProvider.plans!.isEmpty) {
              return _buildErrorState(planProvider);
            }

            if (planProvider.plans?.isEmpty ?? true) {
              return _buildEmptyState();
            }

            if (selectedPlanId == null && planProvider.plans!.isNotEmpty) {
              selectedPlanId = planProvider.plans!.first.id;
              investmentAmount = double.parse(
                planProvider.plans!.first.minAmount ?? '100',
              );
            }

            final selectedPlan = planProvider.plans!.firstWhere(
              (plan) => plan.id == selectedPlanId,
            );
            final profits = calculateProfit(
              investmentAmount,
              selectedPlan.dailyRoi ?? '0',
              selectedPlan.durationDays ?? 0,
            );
            final minAmount = double.parse(selectedPlan.minAmount ?? '100');
            final maxAmount = double.parse(selectedPlan.maxAmount ?? '1000');

            return RefreshIndicator(
              onRefresh: () => planProvider.fetchPlans(),
              color: AppColor.primaryColor,
              backgroundColor: AppColor.secondaryPrimaryColor,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    _buildHeader(),
                    SizedBox(height: 24.h),
                    _buildPlanSelector(planProvider),
                    SizedBox(height: 24.h),
                    _buildAmountSelector(selectedPlan, minAmount, maxAmount),
                    SizedBox(height: 24.h),
                    _buildProfitDisplay(selectedPlan, profits),
                    /*SizedBox(height: 24.h),
                    AppButton.primary(
                      onPressed: () {},
                      text: 'Start Investment',
                      icon: Icons.rocket_launch,
                      height: 50.h,
                      fontSize: 14.sp,
                    ),*/
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(23.w),
      decoration: BoxDecoration(
        gradient: AppColor.screenGradientBgColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calculate_outlined,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 16.h),
          AppText.large(
            'Investment Calculator',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          SizedBox(height: 8.h),
          AppText.small(
            'Calculate your potential returns',
            color: Colors.white.withOpacity(0.85),
            fontSize: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSelector(PlanProvider planProvider) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.lighterBlue.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primaryColor.withOpacity(0.3),
                      AppColor.lighterGreen.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.dashboard_customize_rounded,
                  color: AppColor.lighterGreen,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 16.w),
              AppText.large(
                'Select Investment Plan',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.white,
              ),
            ],
          ),
          SizedBox(height: 15.h),
          ...planProvider.plans!.map((plan) {
            final isSelected = plan.id == selectedPlanId;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedPlanId = plan.id;
                  investmentAmount = double.parse(plan.minAmount ?? '100');
                });
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColor.primaryColor,
                            AppColor.lighterGreen,
                          ],
                        )
                      :AppColor.cardGradientBgColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColor.lighterGreen.withOpacity(0.5)
                        : AppColor.primaryColor.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColor.primaryColor.withOpacity(0.4),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : AppColor.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.diamond_outlined,
                        color: isSelected
                            ? Colors.white
                            : AppColor.primaryColor,
                        size: 15.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.medium(
                            plan.name ?? 'Plan',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.9),
                          ),
                          SizedBox(height: 6.h),
                          AppText.small(
                            '\$${double.parse(plan.minAmount ?? '0').toStringAsFixed(0)} - \$${double.parse(plan.maxAmount ?? '0').toStringAsFixed(0)}',
                            color: isSelected
                                ? Colors.white.withOpacity(0.85)
                                : Colors.white.withOpacity(0.6),
                            fontSize: 10,
                          ),
                          SizedBox(height: 2.h),
                          AppText.small(
                            '${plan.durationDays} days',
                            color: isSelected
                                ? Colors.white.withOpacity(0.85)
                                : Colors.white.withOpacity(0.6),
                            fontSize: 10,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.25),
                                  Colors.white.withOpacity(0.15),
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  AppColor.lighterGreen.withOpacity(0.3),
                                  AppColor.primaryColor.withOpacity(0.3),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: AppText.small(
                        '${plan.dailyRoi}%',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? Colors.white
                            : AppColor.lighterGreen,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAmountSelector(
    selectedPlan,
    double minAmount,
    double maxAmount,
  ) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.lighterBlue.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.lighterGreen.withOpacity(0.3),
                      AppColor.primaryColor.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.payments_rounded,
                  color: AppColor.lighterGreen,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 16.w),
              AppText.large(
                'Investment Amount',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.white,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(28.w),
            decoration: BoxDecoration(
              gradient: AppColor.primaryGradient,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                AppText.small(
                  'Amount',
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 3.h),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.white, Colors.white.withOpacity(0.95)],
                  ).createShader(bounds),
                  child: AppText.large(
                    '\$${investmentAmount.toStringAsFixed(2)}',
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMinMaxLabel('Min', minAmount),
              _buildMinMaxLabel('Max', maxAmount),
            ],
          ),
          SizedBox(height: 16.h),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6.h,
              activeTrackColor: AppColor.white.withOpacity(0.2),
              inactiveTrackColor: AppColor.primaryColor,
              thumbColor: AppColor.info,
              thumbShape: _CustomThumbShape(
                thumbRadius: 12.r,
                iconSize: 16.sp,
              ),
              overlayColor: AppColor.primaryColor.withOpacity(0.2),
            ),
            child: Slider(
              value: investmentAmount,
              min: minAmount,
              max: maxAmount,
              divisions: ((maxAmount - minAmount) / (minAmount / 10)).toInt(),
              onChanged: (value) {
                setState(() {
                  investmentAmount = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinMaxLabel(String label, double amount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor.withOpacity(0.2),
            AppColor.lighterGreen.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText.small(
            '$label: ',
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          AppText.small(
            '\$${amount.toStringAsFixed(0)}',
            color: AppColor.lighterGreen,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }

  Widget _buildProfitDisplay(selectedPlan, Map<String, dynamic> profits) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.lighterBlue.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.lighterBlue.withOpacity(0.3),
                      AppColor.primaryColor.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: AppColor.lighterGreen,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 16.w),
              AppText.large(
                'Profit Breakdown',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.white,
              ),
            ],
          ),
          SizedBox(height: 15.h),
          _buildProfitRow(
            'Daily ROI',
            '${selectedPlan.dailyRoi}%',
            Icons.trending_up,
            AppColor.primaryColor,
          ),
          _buildProfitRow(
            'Duration',
            '${selectedPlan.durationDays} days',
            Icons.calendar_today,
            AppColor.primaryColor,
          ),
          _buildProfitRow(
            'Daily Profit',
            '\$${profits['dailyProfit']}',
            Icons.attach_money,
            AppColor.lighterGreen,
          ),
          _buildProfitRow(
            'Total Profit',
            '\$${profits['totalProfit']}',
            Icons.account_balance_wallet,
            AppColor.success,
          ),
          SizedBox(height: 20.h),
          Container(
            height: 2.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primaryColor.withOpacity(0.5),
                  AppColor.lighterGreen.withOpacity(0.5),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(28.w),
            decoration: BoxDecoration(
              gradient: AppColor.primaryGradient,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.stars_rounded, color: Colors.white, size: 14.sp),
                    SizedBox(width: 3.w),
                    AppText.medium(
                      'TOTAL RETURN',
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                AppText.large(
                  '\$${profits['totalReturn']}',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: AppText.small(
                    'After ${selectedPlan.durationDays} days',
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: AppText.medium(
              label,
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppText.medium(
            value,
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(PlanProvider planProvider) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          gradient: AppColor.glassGradient,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColor.error.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColor.error.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 56.sp,
                color: AppColor.error,
              ),
            ),
            SizedBox(height: 20.h),
            AppText.large(
              'Failed to Load Plans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            SizedBox(height: 12.h),
            AppText.small(
              planProvider.errorMessage ?? 'Unknown error',
              color: Colors.white70,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => planProvider.fetchPlans(),
                borderRadius: BorderRadius.circular(12.r),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppColor.primaryGradient,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 28.w,
                      vertical: 14.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, color: Colors.white, size: 20.sp),
                        SizedBox(width: 8.w),
                        AppText.medium(
                          'Retry',
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.all(40.w),
        decoration: BoxDecoration(
          gradient: AppColor.glassGradient,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColor.primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.primaryColor.withOpacity(0.3),
                    AppColor.lighterGreen.withOpacity(0.3),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 56.sp,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 20.h),
            AppText.large(
              'No Plans Available',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            SizedBox(height: 12.h),
            AppText.small(
              'Investment plans will appear here',
              color: Colors.white70,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
class _CustomThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final double iconSize;

  const _CustomThumbShape({
    required this.thumbRadius,
    required this.iconSize,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    // Draw outer circle
    final paint = Paint()
      ..color = AppColor.secondaryPrimaryColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius, paint);

    // Draw white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.w;

    canvas.drawCircle(center, thumbRadius, borderPaint);

    // Draw icon
    final icon = Icons.rocket_launch;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: iconSize,
        fontFamily: icon.fontFamily,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }
}
