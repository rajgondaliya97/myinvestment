import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../utils/app_color.dart';
import '../../../view_model/pan_provider.dart';
import '../../../model/plan_model/get_plan_model.dart';

class TariffCardWithAPI extends StatefulWidget {
  final String selectedTariff;
  final Function(String, GetPlanModelData) onTariffChanged;

  const TariffCardWithAPI({
    Key? key,
    required this.selectedTariff,
    required this.onTariffChanged,
  }) : super(key: key);

  @override
  State<TariffCardWithAPI> createState() => _TariffCardWithAPIState();
}

class _TariffCardWithAPIState extends State<TariffCardWithAPI> {
  @override
  void initState() {
    super.initState();
    // Fetch plans when widget initializes
    Future.microtask(() {
      final planProvider = context.read<PlanProvider>();
      planProvider.fetchPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlanProvider>(
      builder: (context, planProvider, child) {
        // Loading State
        if (planProvider.isLoading) {
          return _buildLoadingShimmer();
        }

        // Error State
        if (planProvider.hasError) {
          return _buildErrorWidget(planProvider.errorMessage ?? 'Unknown error');
        }

        // Empty State
        final plans = planProvider.plans ?? [];
        if (plans.isEmpty) {
          return _buildEmptyWidget();
        }

        // Success State - Display Plans
        return _buildTariffCards(plans, planProvider);
      },
    );
  }

  /// Build tariff cards from API data
  Widget _buildTariffCards(List<GetPlanModelData> plans, PlanProvider planProvider) {
    // Get first plan ID for auto-selection
    final firstPlanId = plans.isNotEmpty ? plans.first.id.toString() : '';
    final isFirstPlanSelected = widget.selectedTariff.isEmpty || widget.selectedTariff == firstPlanId;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColor.lighterGreen.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            'TARIFF',
            fontSize: 12,
            color: Colors.grey[400],
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 16.h),
          ...List.generate(
            plans.length,
                (index) {
              final plan = plans[index];
              final planId = plan.id.toString();
              final isSelected = widget.selectedTariff == planId;

              // Auto-call onTariffChanged for first plan if not already selected
              if (index == 0 && widget.selectedTariff.isEmpty) {
                Future.microtask(() {
                  widget.onTariffChanged(planId, plan);
                });
              }

              return Column(
                children: [
                  _buildTariffOption(
                    planId,
                    plan.name ?? 'Plan ${index + 1}',
                    '${plan.dailyRoi}% / ${plan.durationDays} days',
                    isSelected,
                    plan,
                    planProvider,
                  ),
                  if (index < plans.length - 1) SizedBox(height: 12.h),
                ],
              );
            },
          ),
          // Show loading indicator if fetching plan details
          if (planProvider.isLoadingDetails)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColor.lighterGreen,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AppText.medium(
                    'Loading plan details...',
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Build single tariff option
  Widget _buildTariffOption(
      String key,
      String title,
      String subtitle,
      bool isSelected,
      GetPlanModelData plan,
      PlanProvider planProvider,
      ) {
    return GestureDetector(
      onTap: () {
        // Fetch detailed plan data when user selects a plan
        print('📤 Plan Tapped: ID=$key, Name=${plan.name}');
        planProvider.fetchPlanDetailsById(plan.id ?? 0);
        widget.onTariffChanged(key, plan);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [
              AppColor.lighterGreen.withOpacity(0.3),
              AppColor.primaryColor.withOpacity(0.2),
            ],
          )
              : LinearGradient(
            colors: [
              AppColor.secondaryPrimaryColor.withOpacity(0.8),
              AppColor.primaryColor.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColor.lighterGreen : Colors.transparent,
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
                  color: isSelected ? AppColor.lighterGreen : Colors.white,
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
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColor.lighterGreen : Colors.grey[600],
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  /// Loading shimmer effect
  Widget _buildLoadingShimmer() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColor.lighterGreen.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            'TARIFF',
            fontSize: 12,
            color: Colors.grey[400],
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 16.h),
          ...List.generate(3, (index) => _buildShimmerPlaceholder(index)),
        ],
      ),
    );
  }

  /// Shimmer placeholder
  Widget _buildShimmerPlaceholder(int index) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor.secondaryPrimaryColor.withOpacity(0.8),
                AppColor.primaryColor.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(120, 16),
                    SizedBox(height: 8.h),
                    _buildShimmerBox(150, 13),
                  ],
                ),
              ),
              _buildShimmerBox(24, 24),
            ],
          ),
        ),
        if (index < 2) SizedBox(height: 12.h),
      ],
    );
  }

  /// Shimmer box
  Widget _buildShimmerBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: _buildShimmerAnimation(),
    );
  }

  /// Shimmer animation effect
  Widget _buildShimmerAnimation() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColor.primaryColor.withOpacity(0.3),
            AppColor.lighterGreen.withOpacity(0.2),
            AppColor.primaryColor.withOpacity(0.3),
          ],
          stops: const [0.1, 0.3, 0.4],
        ).createShader(bounds);
      },
      child: Container(
        color: Colors.white,
      ),
    );
  }

  /// Error state widget
  Widget _buildErrorWidget(String errorMessage) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.red.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 40.sp),
          SizedBox(height: 12.h),
          AppText.medium(
            'Error Loading Plans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.red[400],
          ),
          SizedBox(height: 8.h),
          AppText.medium(
            errorMessage,
            fontSize: 12,
            textAlign: TextAlign.center,
            color: Colors.grey[500],
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () {
              print('🔄 Retrying to fetch plans...');
              context.read<PlanProvider>().fetchPlans();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red[400]!),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: AppText.medium(
                'Retry',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state widget
  Widget _buildEmptyWidget() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColor.lighterGreen.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: AppText.medium(
          'No plans available',
          fontSize: 14,
          color: Colors.grey[500],
        ),
      ),
    );
  }
}