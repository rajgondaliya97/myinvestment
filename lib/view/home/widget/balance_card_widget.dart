import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/utils/app_color.dart';
import 'package:myinvestment/view/home/widget/single_network_details.dart';
import 'package:provider/provider.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:web3dart/web3dart.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../res/services/ReownWalletService.dart';
import 'network_data.dart';
import 'network_selector_sheet.dart';

class BalanceCard extends StatefulWidget {
  final bool showAllNetworks;
  final bool autoRefresh;

  const BalanceCard({
    Key? key,
    this.showAllNetworks = false,
    this.autoRefresh = true,
  }) : super(key: key);

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  bool _isLoadingBalances = false;
  String _nativeBalance = '0.0000';
  String _usdtBalance = '0.00';
  String _gasPrice = '0';
  double _totalUsdValue = 0.0;

  Map<String, double> _allNativeBalances = {};
  Map<String, double> _allUsdtBalances = {};

  String? _lastChainId;
  bool _lastConnected = false;

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

    if (widget.autoRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadBalances();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.autoRefresh) return;

    final walletService = Provider.of<ReownWalletService>(context);
    final currentChainId = walletService.chainId;
    final currentConnected = walletService.isConnected;

    // Reload balances when chain changes or connection state changes
    if (currentChainId != _lastChainId || currentConnected != _lastConnected) {
      _lastChainId = currentChainId;
      _lastConnected = currentConnected;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadBalances();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBalances() async {
    if (!mounted) return;

    final walletService = Provider.of<ReownWalletService>(context, listen: false);

    if (!walletService.isConnected) {
      setState(() {
        _nativeBalance = '0.0000';
        _usdtBalance = '0.00';
        _totalUsdValue = 0.0;
      });
      return;
    }

    setState(() => _isLoadingBalances = true);

    try {
      if (widget.showAllNetworks) {
        await _loadAllNetworkBalances(walletService);
      } else {
        await _loadActiveNetworkBalance(walletService);
      }
    } catch (e) {
      debugPrint('Error loading balances: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingBalances = false);
      }
    }
  }

  Future<void> _loadActiveNetworkBalance(ReownWalletService walletService) async {
    try {
      final balance = await walletService.getBalanceInEther();

      String usdt = '0.00';
      try {
        usdt = await walletService.getUsdtBalance();
      } catch (e) {
        debugPrint('USDT not available on ${walletService.currentNetwork}: $e');
      }

      String gas = '0';
      try {
        final gasPrice = await walletService.getGasPrice();
        gas = gasPrice.getValueInUnit(EtherUnit.gwei).toStringAsFixed(2);
      } catch (e) {
        debugPrint('Gas price error: $e');
      }

      if (mounted) {
        setState(() {
          _nativeBalance = balance;
          _usdtBalance = usdt;
          _gasPrice = gas;
          _totalUsdValue = double.parse(usdt);
        });
      }
    } catch (e) {
      debugPrint('Error loading active network balance: $e');
      rethrow;
    }
  }

  Future<void> _loadAllNetworkBalances(ReownWalletService walletService) async {
    try {
      final nativeBalances = await walletService.getAllBalances();
      final usdtBalances = await walletService.getAllUsdtBalances();

      double totalUsdt = 0.0;
      usdtBalances.forEach((network, balance) {
        totalUsdt += balance;
      });

      if (mounted) {
        setState(() {
          _allNativeBalances = nativeBalances;
          _allUsdtBalances = usdtBalances;
          _totalUsdValue = totalUsdt;

          final activeNetwork = walletService.activeNetwork;
          _nativeBalance = nativeBalances[activeNetwork]?.toStringAsFixed(4) ?? '0.0000';
          _usdtBalance = usdtBalances[activeNetwork]?.toStringAsFixed(2) ?? '0.00';
        });
      }
    } catch (e) {
      debugPrint('Error loading all network balances: $e');
      rethrow;
    }
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

  void _showNetworkSelector(ReownWalletService walletService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NetworkSelectorSheet(
        walletService: walletService,
        onNetworkChanged: _loadBalances,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReownWalletService>(
      builder: (context, walletService, child) {
        if (!walletService.isConnected) {
          return _buildDisconnectedCard();
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColor.cardGradientBgColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColor.primaryColor.withOpacity(0.3),
              width: 1.5.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.primaryColor.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceHeader(walletService),
              _buildExpandedDetails(walletService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceHeader(ReownWalletService walletService) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AppText.medium(
                    widget.showAllNetworks ? 'Total Wallet Balance' : 'Wallet Balance',
                    color: AppColor.grey300.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  SizedBox(width: 8.w),
                  _buildNetworkBadge(walletService),
                ],
              ),
              _buildActionButtons(),
            ],
          ),
          SizedBox(height: 12.h),
          _isLoadingBalances
              ? CircularProgressIndicator(
            color: AppColor.primaryColor,
            strokeWidth: 2,
          )
              : _buildBalanceDisplay(walletService),
        ],
      ),
    );
  }

  Widget _buildNetworkBadge(ReownWalletService walletService) {
    return GestureDetector(
      onTap: () => _showNetworkSelector(walletService),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              NetworkData.getNetworkColor(walletService.currentNetwork).withOpacity(0.3),
              NetworkData.getNetworkColor(walletService.currentNetwork).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: NetworkData.getNetworkColor(walletService.currentNetwork).withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.small(
              NetworkData.getNetworkDisplayName(walletService.currentNetwork),
              color: NetworkData.getNetworkColor(walletService.currentNetwork),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down,
              color: NetworkData.getNetworkColor(walletService.currentNetwork),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        GestureDetector(
          onTap: _loadBalances,
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColor.success.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.refresh,
              color: AppColor.success,
              size: 18.sp,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: _toggleExpanded,
          child: Row(
            children: [
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: Duration(milliseconds: 300),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColor.warning,
                  size: 25.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceDisplay(ReownWalletService walletService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.large(
          '\$${_totalUsdValue.toStringAsFixed(2)}',
          fontWeight: FontWeight.w700,
          color: AppColor.white,
          fontSize: 25,
        ),
        if (!widget.showAllNetworks) ...[
          SizedBox(height: 4.h),
          AppText.small(
            '${_nativeBalance} ${NetworkData.getNativeSymbol(walletService.currentNetwork)}',
            color: AppColor.grey300.withOpacity(0.7),
            fontSize: 12,
          ),
        ],
      ],
    );
  }

  Widget _buildExpandedDetails(ReownWalletService walletService) {
    return SizeTransition(
      sizeFactor: _expandAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColor.black.withOpacity(0.3),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.r),
            bottomRight: Radius.circular(20.r),
          ),
        ),
        child: widget.showAllNetworks
            ? AllNetworksDetails(
          walletService: walletService,
          allNativeBalances: _allNativeBalances,
          allUsdtBalances: _allUsdtBalances,
        )
            : SingleNetworkDetails(
          walletService: walletService,
          nativeBalance: _nativeBalance,
          usdtBalance: _usdtBalance,
          gasPrice: _gasPrice,
        ),
      ),
    );
  }

  Widget _buildDisconnectedCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.grey500.withOpacity(0.2),
            AppColor.black.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColor.grey500.withOpacity(0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 48.sp,
            color: AppColor.grey500,
          ),
          SizedBox(height: 12.h),
          AppText.medium(
            'Wallet Not Connected',
            color: AppColor.grey300,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 8.h),
          AppText.small(
            'Connect your wallet to view balances',
            color: AppColor.grey500,
            fontSize: 12,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}