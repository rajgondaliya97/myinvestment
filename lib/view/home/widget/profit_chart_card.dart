import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../res/app_widget/custom_app_text.dart';
import 'chart_painter.dart';

class ProfitChartCard extends StatelessWidget {
  final List<double> chartData;
  final String selectedPeriod;
  final Function(String) onPeriodSelected;
  final bool isLoading;

  const ProfitChartCard({
    Key? key,
    required this.chartData,
    required this.selectedPeriod,
    required this.onPeriodSelected,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Color(0xFF2A2A2A),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            'Profit Chart',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: 16.h),
          // Period selector
          Row(
            children: ['1D', '1W', '1M', '1Y'].map((period) {
              final isSelected = selectedPeriod == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onPeriodSelected(period),
                  child: Container(
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(0xFF00FF00)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isSelected
                            ? Color(0xFF00FF00)
                            : Color(0xFF2A2A2A),
                        width: 1.w,
                      ),
                    ),
                    child: Center(
                      child: AppText.small(
                        period,
                        color: isSelected ? Colors.black : Colors.grey[400],
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20.h),
          // Chart
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00FF00),
                strokeWidth: 2.w,
              ),
            )
          else
            SizedBox(
              height: 180.h,
              child: CustomPaint(
                size: Size(double.infinity, 180.h),
                painter: ChartPainter(chartData),
              ),
            ),
        ],
      ),
    );
  }
}