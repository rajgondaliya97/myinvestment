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
  String _gasPrice = '0';
  bool _isLoadingBalance = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoadingBalance = true);

    try {
      final walletService = Provider.of<Web3WalletService>(context, listen: false);

      // Get balance
      final balanceStr = await walletService.getBalanceInEther();

      // Get gas price
      final gasPrice = await walletService.getGasPrice();
      final gasPriceGwei = gasPrice.getValueInUnit(EtherUnit.gwei);

      setState(() {
        _balance = balanceStr;
        _gasPrice = gasPriceGwei.toStringAsFixed(2);
        _isLoadingBalance = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to load data: $e';
        _isLoadingBalance = false;
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
                  // Balance Card
                  _buildBalanceCard(walletService),

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
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 12.h),
          _isLoadingBalance
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
            '$_balance ETH',
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_gas_station, size: 14.sp, color: Colors.white70),
              SizedBox(width: 4.w),
              Text(
                'Gas: $_gasPrice Gwei',
                style: TextStyle(
                  fontSize: 12.sp,
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
    // FIX: Format address to show first 6 and last 4 characters
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
    return Column(
      children: [
        // Send Transaction Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showSendDialog(service),
            icon: Icon(Icons.send, size: 20.sp),
            label: const Text('Send ETH'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              side: const BorderSide(color: Colors.blue),
              foregroundColor: Colors.blue,
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
              side: const BorderSide(color: Colors.green),
              foregroundColor: Colors.green,
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

  void _showSendDialog(Web3WalletService service) {
    final toController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Send ETH'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: toController,
              decoration: InputDecoration(
                labelText: 'To Address',
                hintText: '0x...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (ETH)',
                hintText: '0.01',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _sendTransaction(
                service,
                toController.text,
                amountController.text,
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendTransaction(Web3WalletService service, String to, String amount) async {
    if (to.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Please fill all fields')),
      );
      return;
    }

    setState(() => _statusMessage = 'Sending transaction...');

    try {
      final txHash = await service.sendTransaction(
        toAddress: to,
        amountInEther: amount,
      );

      setState(() => _statusMessage = 'Transaction sent! Hash: ${txHash.substring(0, 10)}...');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Transaction sent: ${txHash.substring(0, 20)}...')),
        );
      }

      // Refresh balance
      await _loadWalletData();
    } catch (e) {
      setState(() => _statusMessage = 'Transaction failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Transaction failed: $e')),
        );
      }
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
}