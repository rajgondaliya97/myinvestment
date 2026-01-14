import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/res/services/web_wallet_service.dart';
import 'package:myinvestment/utils/app_color.dart';
import 'package:provider/provider.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:web3dart/web3dart.dart';

class WalletDashboardScreen extends StatefulWidget {
  const WalletDashboardScreen({Key? key}) : super(key: key);

  @override
  State<WalletDashboardScreen> createState() => _WalletDashboardScreenState();
}

class _WalletDashboardScreenState extends State<WalletDashboardScreen> {
  String _balance = '0.0000';
  String _usdtBalance = '0.00';
  String _gasPrice = '0';
  bool _isLoadingBalance = false;
  bool _isLoadingUsdt = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() {
      _isLoadingBalance = true;
      _isLoadingUsdt = true;
    });

    try {
      final walletService = Provider.of<Web3WalletService>(context, listen: false);

      // Get ETH balance
      final balanceStr = await walletService.getBalanceInEther();

      // Get gas price
      final gasPrice = await walletService.getGasPrice();
      final gasPriceGwei = gasPrice.getValueInUnit(EtherUnit.gwei);

      setState(() {
        _balance = balanceStr;
        _gasPrice = gasPriceGwei.toStringAsFixed(2);
        _isLoadingBalance = false;
      });

      // Get USDT balance
      try {
        final usdtBalance = await walletService.getUsdtBalance();
        setState(() {
          _usdtBalance = usdtBalance;
          _isLoadingUsdt = false;
        });
      } catch (e) {
        debugPrint('Error loading USDT: $e');
        setState(() {
          _usdtBalance = '0.00';
          _isLoadingUsdt = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to load data: $e';
        _isLoadingBalance = false;
        _isLoadingUsdt = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWalletData,
          ),
        ],
      ),
      body: Consumer<Web3WalletService>(
        builder: (context, walletService, child) {
          if (!walletService.isConnected) {
            return const Center(
              child: Text('Wallet not connected'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadWalletData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Balance Cards
                  _buildBalanceCard(walletService),

                  SizedBox(height: 12.h),

                  // USDT Balance Card
                  _buildUsdtBalanceCard(walletService),

                  SizedBox(height: 20.h),

                  // Wallet Address Card
                  _buildAddressCard(walletService),

                  SizedBox(height: 20.h),

                  // Network Info
                  _buildNetworkInfo(walletService),

                  SizedBox(height: 20.h),

                  // Status Message
                  if (_statusMessage.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],

                  // Action Buttons
                  _buildActionButtons(walletService),

                  SizedBox(height: 20.h),

                  // Disconnect Button
                  _buildDisconnectButton(walletService),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(Web3WalletService service) {
    // Get the native token symbol based on network
    String getNativeTokenSymbol() {
      switch (service.currentNetwork?.toLowerCase()) {
        case 'bsc':
          return 'BNB';
        case 'polygon':
          return 'MATIC';
        case 'ethereum':
        case 'mainnet':
        default:
          return 'ETH';
      }
    }

    final nativeSymbol = getNativeTokenSymbol();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: service.currentNetwork == 'bsc'
              ? [Colors.amber.shade700, Colors.amber.shade900]
              : [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: (service.currentNetwork == 'bsc' ? Colors.amber : Colors.blue)
                .withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, size: 20.sp, color: Colors.white70),
              SizedBox(width: 8.w),
              Text(
                '$nativeSymbol Balance',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _isLoadingBalance
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : Text(
            '$_balance $nativeSymbol',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.local_gas_station, size: 12.sp, color: Colors.white70),
              SizedBox(width: 4.w),
              Text(
                'Gas: $_gasPrice Gwei',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsdtBalanceCard(Web3WalletService service) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monetization_on, size: 20.sp, color: Colors.white70),
              SizedBox(width: 8.w),
              Text(
                'USDT Balance',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _isLoadingUsdt
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$$_usdtBalance',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'USDT',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Web3WalletService service) {
    String formatAddress(String? address) {
      if (address == null || address.length < 10) return address ?? 'N/A';
      return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_circle, color: Colors.blue, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Wallet Address',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    formatAddress(service.address),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  icon: Icon(Icons.copy, size: 20.sp, color: Colors.blue),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    if (service.address != null) {
                      Clipboard.setData(ClipboardData(text: service.address!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📋 Address copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkInfo(Web3WalletService service) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          Icon(Icons.link, color: Colors.orange, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Network',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _getNetworkDisplayName(service.currentNetwork),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.swap_horiz, color: Colors.blue, size: 24.sp),
            onPressed: () => _showNetworkSelector(service),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Web3WalletService service) {
    String getNativeTokenSymbol() {
      switch (service.currentNetwork?.toLowerCase()) {
        case 'bsc':
          return 'BNB';
        case 'polygon':
          return 'MATIC';
        case 'ethereum':
        case 'mainnet':
        default:
          return 'ETH';
      }
    }

    final nativeSymbol = getNativeTokenSymbol();

    return Column(
      children: [
        // Send Native Token Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showSendDialog(service, isUsdt: false),
            icon: Icon(Icons.send, size: 20.sp),
            label: Text('Send $nativeSymbol'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              side: BorderSide(
                color: service.currentNetwork == 'bsc' ? Colors.amber : Colors.blue,
              ),
              foregroundColor: service.currentNetwork == 'bsc' ? Colors.amber : Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // Send USDT Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showSendDialog(service, isUsdt: true),
            icon: Icon(Icons.monetization_on, size: 20.sp),
            label: const Text('Send USDT'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              side: const BorderSide(color: Colors.green),
              foregroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // Sign Message Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showSignMessageDialog(service),
            icon: Icon(Icons.edit, size: 20.sp),
            label: const Text('Sign Message'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              side: const BorderSide(color: Colors.orange),
              foregroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisconnectButton(Web3WalletService service) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showDisconnectDialog(service),
        icon: Icon(Icons.logout, size: 20.sp),
        label: const Text('Disconnect Wallet'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[700],
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  String _getNetworkDisplayName(String? network) {
    switch (network) {
      case 'ethereum':
        return 'Ethereum Mainnet';
      case 'polygon':
        return 'Polygon';
      case 'bsc':
        return 'Binance Smart Chain';
      default:
        return network ?? 'Unknown';
    }
  }

  void _showNetworkSelector(Web3WalletService service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Network',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20.h),
            _buildNetworkOption(service, 'ethereum', 'Ethereum Mainnet', Icons.currency_exchange),
            _buildNetworkOption(service, 'polygon', 'Polygon', Icons.hexagon),
            _buildNetworkOption(service, 'bsc', 'Binance Smart Chain', Icons.attach_money),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkOption(Web3WalletService service, String network, String name, IconData icon) {
    final isSelected = service.currentNetwork == network;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
      title: Text(
        name,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () async {
        Navigator.pop(context);
        try {
          await service.switchNetwork(network);
          await _loadWalletData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('✅ Switched to $name')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('❌ Failed to switch network: $e')),
            );
          }
        }
      },
    );
  }

  void _showSendDialog(Web3WalletService service, {required bool isUsdt}) {
    final toController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Icon(
              isUsdt ? Icons.monetization_on : Icons.send,
              color: isUsdt ? Colors.green : Colors.blue,
            ),
            SizedBox(width: 8.w),
            Text(isUsdt ? 'Send USDT' : 'Send ${_getNativeTokenSymbol(service)}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Available Balance Display
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available:',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12.sp,
                      ),
                    ),
                    Text(
                      isUsdt ? '$_usdtBalance USDT' : '$_balance ${_getNativeTokenSymbol(service)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // To Address Input
              Text(
                'Recipient Address',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: toController,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  hintText: '0x...',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.paste, color: Colors.blue, size: 20.sp),
                    onPressed: () async {
                      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                      if (clipboardData?.text != null) {
                        toController.text = clipboardData!.text!;
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Amount Input
              Text(
                'Amount',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: isUsdt ? '0.00' : '0.0000',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Set max amount
                            if (isUsdt) {
                              amountController.text = _usdtBalance;
                            } else {
                              amountController.text = _balance;
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          ),
                          child: Text(
                            'MAX',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          isUsdt ? 'USDT' : _getNativeTokenSymbol(service),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Warning Message
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Double-check the address. Transactions cannot be reversed!',
                        style: TextStyle(
                          color: Colors.orange[200],
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate inputs
              if (toController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Please enter recipient address')),
                );
                return;
              }
              if (amountController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Please enter amount')),
                );
                return;
              }

              // Close current dialog and show confirmation
              Navigator.pop(context);
              _showConfirmationDialog(
                service,
                toController.text.trim(),
                amountController.text.trim(),
                isUsdt: isUsdt,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isUsdt ? Colors.green : Colors.blue,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
  void _showConfirmationDialog(
      Web3WalletService service,
      String toAddress,
      String amount,
      {required bool isUsdt}
      ) {
    final tokenSymbol = isUsdt ? 'USDT' : _getNativeTokenSymbol(service);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 8.w),
            const Text('Confirm Transaction'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount
              _buildConfirmationRow(
                'Amount',
                '$amount $tokenSymbol',
                Colors.green,
                Icons.attach_money,
              ),
              SizedBox(height: 12.h),

              // To Address
              _buildConfirmationRow(
                'To',
                '${toAddress.substring(0, 10)}...${toAddress.substring(toAddress.length - 8)}',
                Colors.blue,
                Icons.person,
              ),
              SizedBox(height: 12.h),

              // From Address
              _buildConfirmationRow(
                'From',
                '${service.address!.substring(0, 10)}...${service.address!.substring(service.address!.length - 8)}',
                Colors.grey,
                Icons.account_balance_wallet,
              ),
              SizedBox(height: 12.h),

              // Network
              _buildConfirmationRow(
                'Network',
                _getNetworkDisplayName(service.currentNetwork),
                Colors.orange,
                Icons.network_check,
              ),
              SizedBox(height: 16.h),

              // Gas Fee Warning
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.blue.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_gas_station, color: Colors.blue, size: 16.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Network Fee',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Current gas price: $_gasPrice Gwei\nYou will need ${_getNativeTokenSymbol(service)} to pay for gas fees.',
                      style: TextStyle(
                        color: Colors.blue[200],
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Final Warning
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'This action cannot be undone. Please verify all details carefully.',
                        style: TextStyle(
                          color: Colors.red[200],
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (isUsdt) {
                await _sendUsdt(service, toAddress, amount);
              } else {
                await _sendTransaction(service, toAddress, amount);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
            ),
            child: const Text('Confirm & Send'),
          ),
        ],
      ),
    );
  }
  Widget _buildConfirmationRow(String label, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _sendUsdt(Web3WalletService service, String to, String amount) async {
    if (to.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Please fill all fields')),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16.h),
            Text(
              'Sending USDT...',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please wait, do not close the app',
              style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    setState(() => _statusMessage = 'Sending USDT transaction...');

    try {
      final txHash = await service.sendUsdt(
        toAddress: to,
        amount: amount,
      );

      // Close loading dialog
      Navigator.pop(context);

      setState(() => _statusMessage = 'USDT sent! Hash: ${txHash.substring(0, 10)}...');

      // Show success dialog
      _showSuccessDialog(
        title: '✅ USDT Sent Successfully!',
        message: 'Your USDT has been sent.',
        txHash: txHash,
        network: service.currentNetwork!,
      );

      await _loadWalletData();
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      setState(() => _statusMessage = 'USDT transaction failed: $e');

      // Show error dialog
      _showErrorDialog('Transaction Failed', e.toString());
    }
  }

  Future<void> _sendTransaction(Web3WalletService service, String to, String amount) async {
    if (to.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Please fill all fields')),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16.h),
            Text(
              'Sending ${_getNativeTokenSymbol(service)}...',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please wait, do not close the app',
              style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    setState(() => _statusMessage = 'Sending transaction...');

    try {
      final txHash = await service.sendTransaction(
        toAddress: to,
        amountInEther: amount,
      );

      // Close loading dialog
      Navigator.pop(context);

      setState(() => _statusMessage = 'Transaction sent! Hash: ${txHash.substring(0, 10)}...');

      // Show success dialog
      _showSuccessDialog(
        title: '✅ Transaction Sent Successfully!',
        message: 'Your ${_getNativeTokenSymbol(service)} has been sent.',
        txHash: txHash,
        network: service.currentNetwork!,
      );

      await _loadWalletData();
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      setState(() => _statusMessage = 'Transaction failed: $e');

      // Show error dialog
      _showErrorDialog('Transaction Failed', e.toString());
    }
  }

  void _showSignMessageDialog(Web3WalletService service) {
    final messageController = TextEditingController(text: 'Hello from Infinite Wealth!');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Sign Message'),
        content: TextField(
          controller: messageController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Message',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _signMessage(service, messageController.text);
            },
            child: const Text('Sign'),
          ),
        ],
      ),
    );
  }

  Future<void> _signMessage(Web3WalletService service, String message) async {
    setState(() => _statusMessage = 'Signing message...');

    try {
      final signature = await service.signMessage(message);

      setState(() => _statusMessage = 'Message signed successfully!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Signature: ${signature.substring(0, 20)}...')),
        );
      }
    } catch (e) {
      setState(() => _statusMessage = 'Signing failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Signing failed: $e')),
        );
      }
    }
  }

  void _showDisconnectDialog(Web3WalletService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Disconnect Wallet'),
        content: const Text('Do you want to delete the stored private key?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _disconnect(service, deleteKey: false);
            },
            child: const Text('Keep Key'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _disconnect(service, deleteKey: true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Key'),
          ),
        ],
      ),
    );
  }

  Future<void> _disconnect(Web3WalletService service, {required bool deleteKey}) async {
    try {
      await service.disconnect(deleteStoredKey: deleteKey);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/import');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Disconnect failed: $e')),
        );
      }
    }
  }
  void _showSuccessDialog({
    required String title,
    required String message,
    required String txHash,
    required String network,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Transaction Hash:',
              style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${txHash.substring(0, 10)}...${txHash.substring(txHash.length - 8)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: Colors.blue, size: 18.sp),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: txHash));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('📋 Transaction hash copied!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Open block explorer
              final explorerUrl = _getTransactionExplorerUrl(network, txHash);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('View on explorer: $explorerUrl')),
              );
            },
            child: const Text('View on Explorer'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
  void _showErrorDialog(String title, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 30),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Error Details:',
              style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              child: Text(
                error,
                style: TextStyle(
                  color: Colors.red[200],
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getNativeTokenSymbol(Web3WalletService service) {
    switch (service.currentNetwork?.toLowerCase()) {
      case 'bsc':
        return 'BNB';
      case 'polygon':
        return 'MATIC';
      case 'ethereum':
      case 'mainnet':
      default:
        return 'ETH';
    }
  }

  String _getTransactionExplorerUrl(String network, String txHash) {
    String baseUrl;
    switch (network.toLowerCase()) {
      case 'bsc':
        baseUrl = 'https://bscscan.com';
        break;
      case 'polygon':
        baseUrl = 'https://polygonscan.com';
        break;
      case 'ethereum':
      case 'mainnet':
      default:
        baseUrl = 'https://etherscan.io';
    }
    return '$baseUrl/tx/$txHash';
  }
}