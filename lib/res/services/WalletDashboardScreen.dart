import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import 'ReownWalletService.dart';

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
      final walletService = Provider.of<ReownWalletService>(context, listen: false);

      // Get native balance
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Wallet'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWalletData,
          ),
        ],
      ),
      body: Consumer<ReownWalletService>(
        builder: (context, walletService, child) {
          if (!walletService.isConnected) {
            return const Center(
              child: Text(
                'Wallet not connected',
                style: TextStyle(color: Colors.white),
              ),
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
                        color: Colors.blue.withOpacity(0.2),
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

  Widget _buildBalanceCard(ReownWalletService service) {
    final nativeSymbol = service.getCurrencySymbol();
    final isBSC = service.chainId == '56';

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBSC
              ? [Colors.amber.shade700, Colors.amber.shade900]
              : [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: (isBSC ? Colors.amber : Colors.blue).withOpacity(0.3),
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

  Widget _buildUsdtBalanceCard(ReownWalletService service) {
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
            color: Colors.green.withOpacity(0.3),
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

  Widget _buildAddressCard(ReownWalletService service) {
    String formatAddress(String? address) {
      if (address == null || address.length < 10) return address ?? 'N/A';
      return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_circle, color: Colors.orange, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Wallet Address',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white54,
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
                  icon: Icon(Icons.copy, size: 20.sp, color: Colors.orange),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    if (service.address != null) {
                      Clipboard.setData(ClipboardData(text: service.address!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📋 Address copied to clipboard!'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.green,
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

  Widget _buildNetworkInfo(ReownWalletService service) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
        ),
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
                    color: Colors.white54,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  service.getNetworkName(),
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
            icon: Icon(Icons.swap_horiz, color: Colors.orange, size: 24.sp),
            onPressed: () => _showNetworkSelector(service),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ReownWalletService service) {
    return Column(
      children: [
        // Send Native Token
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showSendDialog(service, isUsdt: false),
            icon: Icon(Icons.send, size: 20.sp),
            label: Text('Send ${service.getCurrencySymbol()}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // Send USDT
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showSendDialog(service, isUsdt: true),
            icon: Icon(Icons.monetization_on, size: 20.sp),
            label: const Text('Send USDT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // Sign Message
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

  Widget _buildDisconnectButton(ReownWalletService service) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await service.disconnect();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/connect');
          }
        },
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

  void _showNetworkSelector(ReownWalletService service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
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
            _buildNetworkOption(service, 'sepolia', 'Sepolia Testnet', Icons.science),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkOption(ReownWalletService service, String network, String name, IconData icon) {
    final isSelected = service.currentNetwork == network;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.orange : Colors.grey),
      title: Text(
        name,
        style: TextStyle(
          color: isSelected ? Colors.orange : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.orange) : null,
      onTap: () async {
        Navigator.pop(context);
        try {
          await service.switchNetwork(network);
          await _loadWalletData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Switched to $name'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Failed to switch network: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  void _showSendDialog(ReownWalletService service, {required bool isUsdt}) {
    final toController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: Row(
          children: [
            Icon(
              isUsdt ? Icons.monetization_on : Icons.send,
              color: isUsdt ? Colors.green : Colors.orange,
            ),
            SizedBox(width: 8.w),
            Text(
              isUsdt ? 'Send USDT' : 'Send ${service.getCurrencySymbol()}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Available Balance
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
                      style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
                    ),
                    Text(
                      isUsdt ? '$_usdtBalance USDT' : '$_balance ${service.getCurrencySymbol()}',
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

              // To Address
              Text(
                'Recipient Address',
                style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: toController,
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: '0x...',
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
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Amount
              Text(
                'Amount',
                style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: isUsdt ? '0.00' : '0.0000',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  suffixText: isUsdt ? 'USDT' : service.getCurrencySymbol(),
                  suffixStyle: TextStyle(color: Colors.grey[400]),
                ),
              ),

              SizedBox(height: 16.h),

              // Warning
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
                        style: TextStyle(color: Colors.orange[200], fontSize: 11.sp),
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
              final to = toController.text.trim();
              final amount = amountController.text.trim();

              if (to.isEmpty || amount.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Please fill all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1C1C1E),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: isUsdt ? Colors.green : Colors.orange),
                      SizedBox(height: 16.h),
                      Text(
                        isUsdt ? 'Sending USDT...' : 'Sending ${service.getCurrencySymbol()}...',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );

              try {
                final txHash = isUsdt
                    ? await service.sendUsdt(toAddress: to, amount: amount)
                    : await service.sendTransaction(toAddress: to, amountInEther: amount);

                Navigator.pop(context); // Close loading

                if (mounted) {
                  _showSuccessDialog(
                    title: '✅ Transaction Sent!',
                    message: 'Your transaction has been submitted.',
                    txHash: txHash,
                    service: service,
                  );
                  await _loadWalletData();
                }
              } catch (e) {
                Navigator.pop(context); // Close loading
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Transaction failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isUsdt ? Colors.green : Colors.orange,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showSignMessageDialog(ReownWalletService service) {
    final messageController = TextEditingController(text: 'Hello from My Investment!');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Sign Message', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: messageController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Message',
            labelStyle: const TextStyle(color: Colors.white54),
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
              try {
                final signature = await service.signMessage(messageController.text);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Signature: ${signature.substring(0, 20)}...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Signing failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Sign'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog({
    required String title,
    required String message,
    required String txHash,
    required ReownWalletService service,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(title, style: const TextStyle(color: Colors.green)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(color: Colors.white)),
            SizedBox(height: 16.h),
            Text('Transaction Hash:', style: TextStyle(color: Colors.grey[400], fontSize: 12.sp)),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '${txHash.substring(0, 10)}...${txHash.substring(txHash.length - 8)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final explorerUrl = service.getTransactionExplorerUrl(txHash);
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
}