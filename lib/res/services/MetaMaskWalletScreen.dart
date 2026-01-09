import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/res/services/meta_mask_service.dart';
import 'package:myinvestment/utils/app_color.dart';
import 'package:provider/provider.dart';

class MetaMaskWalletScreen extends StatefulWidget {
  const MetaMaskWalletScreen({Key? key}) : super(key: key);

  @override
  State<MetaMaskWalletScreen> createState() => _MetaMaskWalletScreenState();
}

class _MetaMaskWalletScreenState extends State<MetaMaskWalletScreen> {
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MetaMask Wallet'),
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
      ),
      body: Consumer<MetaMaskService>(
        builder: (context, metaMaskService, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Card
                _buildStatusCard(metaMaskService),

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

                // Main Action Buttons
                if (!metaMaskService.isConnected)
                  _buildConnectButton(metaMaskService)
                else ...[
                  _buildWalletInfo(metaMaskService),
                  SizedBox(height: 20.h),
                  _buildActionButtons(metaMaskService),
                  SizedBox(height: 20.h),
                  _buildDisconnectButton(metaMaskService),
                ],

                SizedBox(height: 30.h),

                // Instructions
                _buildInstructions(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(MetaMaskService service) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: service.isConnected
              ? [Colors.green.shade700, Colors.green.shade900]
              : [Colors.grey.shade800, Colors.grey.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: (service.isConnected ? Colors.green : Colors.grey)
                .withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              service.isConnected ? Icons.check_circle : Icons.account_balance_wallet,
              color: Colors.white,
              size: 30.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.isConnected ? 'Wallet Connected' : 'No Wallet Connected',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (service.isConnected && service.currentChainId != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Chain ID: ${service.currentChainId}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectButton(MetaMaskService service) {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () async {
        setState(() {
          _isLoading = true;
          _statusMessage = 'Opening MetaMask app...';
        });

        try {
          await service.connect();
          setState(() {
            _statusMessage = 'Successfully connected to MetaMask!';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Wallet connected successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          setState(() {
            _statusMessage = 'Connection failed: ${e.toString()}';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Connection failed: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        } finally {
          setState(() => _isLoading = false);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primaryColor,
        padding: EdgeInsets.symmetric(vertical: 18.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 5,
      ),
      child: _isLoading
          ? SizedBox(
        height: 24.h,
        width: 24.w,
        child: const CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet, size: 24.sp),
          SizedBox(width: 12.w),
          Text(
            'Connect MetaMask Wallet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletInfo(MetaMaskService service) {
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
                    service.currentAddress ?? 'N/A',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, size: 20.sp, color: Colors.blue),
                  onPressed: () {
                    if (service.currentAddress != null) {
                      Clipboard.setData(
                        ClipboardData(text: service.currentAddress!),
                      );
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
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.link, color: Colors.orange, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Network',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              _getNetworkName(service.currentChainId),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(MetaMaskService service) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () async {
            try {
              setState(() => _statusMessage = 'Requesting signature...');
              final signature = await service.signMessage('Hello from Infinite Wealth!');
              setState(() => _statusMessage = 'Message signed successfully!');

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Signature: ${signature.substring(0, 20)}...'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              setState(() => _statusMessage = 'Signature failed: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Sign failed: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          icon: Icon(Icons.edit, size: 20.sp),
          label: Text('Sign Message (Test)'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            side: BorderSide(color: Colors.blue),
            foregroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisconnectButton(MetaMaskService service) {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          setState(() => _statusMessage = 'Disconnecting...');
          await service.disconnect();
          setState(() => _statusMessage = 'Wallet disconnected');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('👋 Wallet disconnected'),
              backgroundColor: Colors.orange,
            ),
          );
        } catch (e) {
          setState(() => _statusMessage = 'Disconnect failed: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Disconnect failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
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
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
              Icon(Icons.info_outline, color: Colors.blue, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'How to Connect',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildInstructionItem('1. Install MetaMask app on your device'),
          _buildInstructionItem('2. Create or import a wallet in MetaMask'),
          _buildInstructionItem('3. Tap "Connect MetaMask Wallet" button'),
          _buildInstructionItem('4. MetaMask app will open automatically'),
          _buildInstructionItem('5. Approve the connection in MetaMask'),
          SizedBox(height: 12.h),
          Text(
            '💡 Tip: Make sure MetaMask app is installed before connecting',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[400],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getNetworkName(String? chainId) {
    if (chainId == null) return 'Unknown';

    switch (chainId) {
      case '1':
        return 'Ethereum Mainnet';
      case '137':
        return 'Polygon';
      case '56':
        return 'Binance Smart Chain';
      case '5':
        return 'Goerli Testnet';
      case '11155111':
        return 'Sepolia Testnet';
      default:
        return 'Chain ID: $chainId';
    }
  }
}