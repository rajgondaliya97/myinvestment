import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/utils/app_color.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../res/services/ReownWalletService.dart';
import 'network_data.dart';

class NetworkSelectorSheet extends StatelessWidget {
  final ReownWalletService walletService;
  final VoidCallback onNetworkChanged;

  const NetworkSelectorSheet({
    Key? key,
    required this.walletService,
    required this.onNetworkChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColor.secondaryPrimaryColor,
            AppColor.primaryColor.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            //color: AppColor.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          SizedBox(height: 20.h),
          Divider(
            color: AppColor.white.withOpacity(0.1),
            height: 1,
            thickness: 1,
          ),
          SizedBox(height: 16.h),
          _buildNetworksList(context),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12.h),
        Container(
          width: 50.w,
          height: 5.h,
          decoration: BoxDecoration(
            gradient: AppColor.primaryGradient,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      gradient: AppColor.primaryGradient,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.network_check,
                      color: AppColor.white,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.large(
                        'Select Network',
                        color: AppColor.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 2.h),
                      AppText.small(
                        'Choose your blockchain network',
                        color: AppColor.grey300.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColor.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: AppColor.white),
                  iconSize: 22.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNetworksList(BuildContext context) {
    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        itemCount: NetworkData.availableNetworks.length,
        itemBuilder: (context, index) {
          final network = NetworkData.availableNetworks[index];
          final networkId = network['id'] as String;
          final isConnected = walletService.connectedNetworks.contains(networkId);
          final isActive = networkId == walletService.activeNetwork;

          return NetworkCard(
            network: network,
            isActive: isActive,
            isConnected: isConnected,
            onTap: () => _handleNetworkTap(context, networkId, network, isConnected, isActive),
          );
        },
      ),
    );
  }

  Future<void> _handleNetworkTap(
      BuildContext context,
      String networkId,
      Map<String, dynamic> network,
      bool isConnected,
      bool isActive,
      ) async {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connecting to ${network['name']}...'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColor.info,
        ),
      );

      try {
        await walletService.addNetwork(networkId);
        await walletService.switchNetwork(networkId);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
            backgroundColor: AppColor.error,
          ),
        );
        return;
      }
    } else if (!isActive) {
      await walletService.switchNetwork(networkId);
    }

    Navigator.pop(context);
    onNetworkChanged();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${network['name']}'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColor.success,
      ),
    );
  }
}

class NetworkCard extends StatelessWidget {
  final Map<String, dynamic> network;
  final bool isActive;
  final bool isConnected;
  final VoidCallback onTap;

  const NetworkCard({
    Key? key,
    required this.network,
    required this.isActive,
    required this.isConnected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final networkColor = network['color'] as Color;
    final networkIcon = network['icon'] as IconData;
    final networkName = network['name'] as String;
    final networkSymbol = network['symbol'] as String;
    final networkDesc = network['description'] as String;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
            colors: [
              networkColor.withOpacity(0.25),
              networkColor.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : AppColor.cardGradientBgColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isActive
                ? networkColor.withOpacity(0.6)
                : AppColor.white.withOpacity(0.1),
            width: isActive ? 2.w : 1.w,
          ),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: networkColor.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ]
              : [],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              _buildNetworkIcon(networkColor, networkIcon),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildNetworkInfo(networkName, networkDesc, networkSymbol, networkColor),
              ),
              SizedBox(width: 12.w),
              _buildStatusIndicator(networkColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkIcon(Color networkColor, IconData networkIcon) {
    return Container(
      width: 45.w,
      height: 45.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [networkColor, networkColor.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: networkColor.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(networkIcon, color: AppColor.white, size: 28.sp),
    );
  }

  Widget _buildNetworkInfo(String name, String desc, String symbol, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: AppText.medium(
                name,
                color: AppColor.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.w),
            if (!isConnected)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColor.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: AppColor.orange.withOpacity(0.5)),
                ),
                child: AppText.small(
                  'NOT CONNECTED',
                  color: AppColor.orange,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        SizedBox(height: 4.h),
        AppText.small(
          desc,
          color: AppColor.grey300.withOpacity(0.6),
          fontSize: 11,
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.toll, color: color, size: 12.sp),
              SizedBox(width: 4.w),
              AppText.small(
                symbol,
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(Color networkColor) {
    return Column(
      children: [
        if (isActive)
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: AppColor.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(Icons.check_circle, color: AppColor.white, size: 16.sp),
          )
        else
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColor.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.white.withOpacity(0.2)),
            ),
            child: Icon(
              isConnected ? Icons.arrow_forward_ios : Icons.add_circle_outline,
              color: isConnected ? AppColor.grey300 : AppColor.primaryColor,
              size: 12.sp,
            ),
          ),
        if (isActive) ...[
          SizedBox(height: 6.h),
          AppText.small(
            'ACTIVE',
            color: AppColor.success,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ],
      ],
    );
  }
}