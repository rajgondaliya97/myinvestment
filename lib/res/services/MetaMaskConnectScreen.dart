import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'ReownWalletService.dart';

class MetaMaskConnectScreen extends StatefulWidget {
  const MetaMaskConnectScreen({Key? key}) : super(key: key);

  @override
  State<MetaMaskConnectScreen> createState() => _MetaMaskConnectScreenState();
}

class _MetaMaskConnectScreenState extends State<MetaMaskConnectScreen> {
  bool _isConnecting = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Wallet Logo
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 60.sp,
                    color: Colors.orange,
                  ),
                ),
          
                SizedBox(height: 32.h),
          
                // Title
                Text(
                  'Connect Your Wallet',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
          
                SizedBox(height: 16.h),
          
                // Description
                Text(
                  'Connect with MetaMask, Trust Wallet,\nRainbow, and 300+ wallets',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
          
                SizedBox(height: 48.h),
          
                // Connect Button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _isConnecting ? null : _connectWallet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: _isConnecting
                        ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wallet, size: 24.sp),
                        SizedBox(width: 12.w),
                        Text(
                          'Connect Wallet',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          
                SizedBox(height: 24.h),
          
                // Instructions
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Make sure MetaMask or your preferred wallet app is installed on your device',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          
                // Error Message
                if (_errorMessage != null) ...[
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
          
                // Info Cards
                _buildInfoCard(
                  icon: Icons.security,
                  title: 'Secure',
                  description: 'Your keys, your crypto',
                ),
          
                SizedBox(height: 12.h),
          
                _buildInfoCard(
                  icon: Icons.speed,
                  title: 'Fast',
                  description: 'Quick and easy connection',
                ),
          
                SizedBox(height: 12.h),
          
                _buildInfoCard(
                  icon: Icons.link,
                  title: 'Multi-Chain',
                  description: 'BSC, Ethereum, Polygon & more',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: Colors.orange,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _connectWallet() async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      final reownService = Provider.of<ReownWalletService>(
        context,
        listen: false,
      );

      debugPrint('🔗 Opening wallet connection modal...');

      // Add listener to detect connection changes
      void connectionListener() {
        if (reownService.isConnected && mounted) {
          debugPrint('✅ Wallet connected! Navigating to dashboard...');
          // Remove listener
          reownService.removeListener(connectionListener);
          // Navigate to dashboard
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      }

      // Add the listener
      reownService.addListener(connectionListener);

      // Open the Reown AppKit modal
      await reownService.connect();

      // After modal closes, check connection status
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        if (!reownService.isConnected) {
          // Remove listener if not connected
          reownService.removeListener(connectionListener);
          setState(() {
            _errorMessage = 'Connection was cancelled. Please try again.';
            _isConnecting = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Connection failed: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Connection failed: ${e.toString()}';
          _isConnecting = false;
        });
      }
    }
  }
}