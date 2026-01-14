import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/utils/app_color.dart';
import 'package:myinvestment/res/services/web_wallet_service.dart';
import 'package:provider/provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import '../../../res/app_widget/custom_app_text.dart';

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

class _BalanceCardState extends State<BalanceCard> with SingleTickerProviderStateMixin {
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBalances() async {
    if (!mounted) return;

    final walletService = Provider.of<Web3WalletService>(context, listen: false);

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

  Future<void> _loadActiveNetworkBalance(Web3WalletService walletService) async {
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

  Future<void> _loadAllNetworkBalances(Web3WalletService walletService) async {
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

  void _showNetworkSelector(Web3WalletService walletService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          border: Border.all(
            color: Color(0xFF00FF00).withOpacity(0.3),
            width: 1.w,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.large(
                    'Select Network',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Divider(color: Colors.grey[800], height: 1),
            SizedBox(height: 12.h),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                children: walletService.connectedNetworks.map((network) {
                  final isActive = network == walletService.activeNetwork;
                  return _buildNetworkOption(
                    network: network,
                    isActive: isActive,
                    onTap: () async {
                      if (!isActive) {
                        Navigator.pop(context);
                        await walletService.switchNetwork(network);
                        _loadBalances();
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkOption({
    required String network,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isActive
              ? _getNetworkColor(network).withOpacity(0.15)
              : Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isActive
                ? _getNetworkColor(network).withOpacity(0.5)
                : Colors.grey[800]!,
            width: isActive ? 2.w : 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: _getNetworkColor(network).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                _getNetworkIcon(network),
                color: _getNetworkColor(network),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.medium(
                    _getNetworkDisplayName(network),
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 2.h),
                  AppText.small(
                    _getNativeSymbol(network),
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ],
              ),
            ),
            if (isActive)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Color(0xFF00FF00).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Color(0xFF00FF00).withOpacity(0.5),
                  ),
                ),
                child: AppText.small(
                  'ACTIVE',
                  color: Color(0xFF00FF00),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[600],
                size: 16.sp,
              ),
          ],
        ),
      ),
    );
  }

  String _getNativeSymbol(String? network) {
    switch (network?.toLowerCase()) {
      case 'bsc':
        return 'BNB';
      case 'polygon':
        return 'MATIC';
      case 'ethereum':
      case 'sepolia':
      case 'goerli':
      default:
        return 'ETH';
    }
  }

  Color _getNetworkColor(String? network) {
    switch (network?.toLowerCase()) {
      case 'bsc':
        return Color(0xFFF3BA2F);
      case 'polygon':
        return Color(0xFF8247E5);
      case 'ethereum':
      case 'sepolia':
      case 'goerli':
      default:
        return Color(0xFF627EEA);
    }
  }

  IconData _getNetworkIcon(String? network) {
    switch (network?.toLowerCase()) {
      case 'ethereum':
      case 'sepolia':
      case 'goerli':
        return Icons.currency_exchange;
      case 'bsc':
        return Icons.attach_money;
      case 'polygon':
        return Icons.hexagon;
      default:
        return Icons.currency_exchange;
    }
  }

  String _getNetworkDisplayName(String? network) {
    switch (network?.toLowerCase()) {
      case 'ethereum':
        return 'Ethereum';
      case 'polygon':
        return 'Polygon';
      case 'bsc':
        return 'BSC';
      case 'sepolia':
        return 'Sepolia';
      case 'goerli':
        return 'Goerli';
      default:
        return network ?? 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Web3WalletService>(
      builder: (context, walletService, child) {
        if (!walletService.isConnected) {
          return _buildDisconnectedCard();
        }

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
              Padding(
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
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () => _showNetworkSelector(walletService),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: _getNetworkColor(walletService.currentNetwork).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: _getNetworkColor(walletService.currentNetwork).withOpacity(0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppText.small(
                                      walletService.currentNetwork?.toUpperCase() ?? 'ETH',
                                      color: _getNetworkColor(walletService.currentNetwork),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: _getNetworkColor(walletService.currentNetwork),
                                      size: 14.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _loadBalances,
                              child: Icon(
                                Icons.refresh,
                                color: Color(0xFF00FF00),
                                size: 18.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
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
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _isLoadingBalances
                        ? CircularProgressIndicator(
                      color: Color(0xFF00FF00),
                      strokeWidth: 2,
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.large(
                          '\$${_totalUsdValue.toStringAsFixed(2)}',
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 25,
                        ),
                        if (!widget.showAllNetworks) ...[
                          SizedBox(height: 4.h),
                          AppText.small(
                            '${_nativeBalance} ${_getNativeSymbol(walletService.currentNetwork)}',
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

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
                  child: widget.showAllNetworks
                      ? _buildAllNetworksDetails(walletService)
                      : _buildSingleNetworkDetails(walletService),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDisconnectedCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[900]!.withOpacity(0.8),
            Colors.grey[800]!.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 48.sp,
            color: Colors.grey[600],
          ),
          SizedBox(height: 12.h),
          AppText.medium(
            'Wallet Not Connected',
            color: Colors.grey[400],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 8.h),
          AppText.small(
            'Connect your wallet to view balances',
            color: Colors.grey[600],
            fontSize: 12,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSingleNetworkDetails(Web3WalletService walletService) {
    final nativeSymbol = _getNativeSymbol(walletService.currentNetwork);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText.medium(
              'WALLET ASSETS',
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            AppText.medium(
              'BALANCE',
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        SizedBox(height: 16.h),

        _buildCurrencyItem(
          nativeSymbol,
          double.parse(_nativeBalance),
          _getNetworkIcon(walletService.currentNetwork),
          _getNetworkColor(walletService.currentNetwork),
          symbol: nativeSymbol,
        ),
        SizedBox(height: 12.h),

        _buildCurrencyItem(
          'TETHER USD',
          double.parse(_usdtBalance),
          Icons.monetization_on,
          Color(0xFF26A17B),
          symbol: 'USDT',
        ),

        SizedBox(height: 16.h),

        _buildNetworkInfoRow(walletService),
      ],
    );
  }

  Widget _buildAllNetworksDetails(Web3WalletService walletService) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText.medium(
              'ALL NETWORKS',
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            AppText.medium(
              'BALANCE',
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        SizedBox(height: 16.h),

        ..._allNativeBalances.entries.map((entry) {
          final network = entry.key;
          final balance = entry.value;
          final symbol = _getNativeSymbol(network);

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildNetworkBalanceRow(
              network: network,
              balance: balance,
              symbol: symbol,
              isActive: network == walletService.activeNetwork,
            ),
          );
        }).toList(),

        SizedBox(height: 16.h),

        AppText.medium(
          'USDT BALANCES',
          color: Colors.grey[500],
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 12.h),

        ..._allUsdtBalances.entries.map((entry) {
          final network = entry.key;
          final balance = entry.value;

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildNetworkBalanceRow(
              network: network,
              balance: balance,
              symbol: 'USDT',
              isActive: network == walletService.activeNetwork,
              isUsdt: true,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildNetworkBalanceRow({
    required String network,
    required double balance,
    required String symbol,
    required bool isActive,
    bool isUsdt = false,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isActive
            ? _getNetworkColor(network).withOpacity(0.1)
            : Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isActive
              ? _getNetworkColor(network).withOpacity(0.5)
              : Colors.grey[800]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isUsdt ? Icons.monetization_on : _getNetworkIcon(network),
            color: isUsdt ? Color(0xFF26A17B) : _getNetworkColor(network),
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.small(
                  _getNetworkDisplayName(network),
                  color: isActive ? Colors.white : Colors.grey[400],
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                SizedBox(height: 2.h),
                AppText.medium(
                  '${balance.toStringAsFixed(isUsdt ? 2 : 4)} $symbol',
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Color(0xFF00FF00).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: AppText.small(
                'ACTIVE',
                color: Color(0xFF00FF00),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem(
      String name,
      double amount,
      IconData icon,
      Color color,
      {String? symbol}
      ) {
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
          Expanded(
            child: Column(
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
                  symbol != null && (symbol == 'ETH' || symbol == 'BNB' || symbol == 'MATIC')
                      ? amount.toStringAsFixed(4)
                      : amount.toStringAsFixed(2),
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ],
            ),
          ),
          if (symbol != null)
            AppText.medium(
              symbol,
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
        ],
      ),
    );
  }

  Widget _buildNetworkInfoRow(Web3WalletService walletService) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Color(0xFF000000).withOpacity(0.3),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: Colors.grey[800]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.network_check,
                color: _getNetworkColor(walletService.currentNetwork),
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.small(
                    'Active Network',
                    color: Colors.grey[500],
                    fontSize: 10,
                  ),
                  AppText.medium(
                    _getNetworkDisplayName(walletService.currentNetwork),
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ],
          ),
          if (_gasPrice != '0')
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText.small(
                  'Gas Price',
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
                AppText.medium(
                  '$_gasPrice Gwei',
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
        ],
      ),
    );
  }
}