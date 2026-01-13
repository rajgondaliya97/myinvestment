import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/res/services/web_wallet_service.dart';
import 'package:myinvestment/utils/app_color.dart';
import 'package:provider/provider.dart';

class WalletImportScreen extends StatefulWidget {
  const WalletImportScreen({Key? key}) : super(key: key);

  @override
  State<WalletImportScreen> createState() => _WalletImportScreenState();
}

class _WalletImportScreenState extends State<WalletImportScreen> {
  final _privateKeyController = TextEditingController();
  bool _isLoading = false;
  bool _obscureKey = true;
  bool _saveKey = true;
  String _errorMessage = '';

  @override
  void dispose() {
    _privateKeyController.dispose();
    super.dispose();
  }

  Future<void> _importWallet() async {
    if (_privateKeyController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your private key');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final walletService = Provider.of<Web3WalletService>(context, listen: false);

      await walletService.importWalletFromPrivateKey(
        _privateKeyController.text.trim(),
        saveKey: _saveKey,
      );

      if (mounted) {
        // Navigate to wallet screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const WalletDashboardScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      setState(() {
        _privateKeyController.text = clipboardData!.text!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Wallet'),
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Icon
            Center(
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 60.sp,
                  color: AppColor.primaryColor,
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Title
            Text(
              'Import Your Wallet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 12.h),

            // Description
            Text(
              'Enter your MetaMask private key to access your wallet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[400],
              ),
            ),

            SizedBox(height: 32.h),

            // Private Key Input
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _errorMessage.isNotEmpty
                      ? Colors.red
                      : Colors.grey[800]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.key, color: Colors.blue, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Private Key',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _privateKeyController,
                    obscureText: _obscureKey,
                    maxLines: _obscureKey ? 1 : 3,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: '0x1234567890abcdef...',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                      border: InputBorder.none,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _obscureKey ? Icons.visibility : Icons.visibility_off,
                              size: 20.sp,
                              color: Colors.grey[400],
                            ),
                            onPressed: () {
                              setState(() => _obscureKey = !_obscureKey);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.paste,
                              size: 20.sp,
                              color: Colors.blue,
                            ),
                            onPressed: _pasteFromClipboard,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_errorMessage.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 20.h),

            // Save Key Checkbox
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: CheckboxListTile(
                value: _saveKey,
                onChanged: (value) {
                  setState(() => _saveKey = value ?? true);
                },
                title: Text(
                  'Remember this wallet',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white),
                ),
                subtitle: Text(
                  'Private key will be encrypted and stored securely',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                ),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.blue,
              ),
            ),

            SizedBox(height: 32.h),

            // Import Button
            ElevatedButton(
              onPressed: _isLoading ? null : _importWallet,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 18.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.import_export, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Import Wallet',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Security Warning
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange, size: 24.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Security Warning',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildWarningItem('Never share your private key with anyone'),
                  _buildWarningItem('We will never ask for your private key'),
                  _buildWarningItem('Make sure you trust this app before importing'),
                  _buildWarningItem('Keep your private key backed up safely'),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // How to find private key
            _buildHowToSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.orange, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.orange[200],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToSection() {
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
              Icon(Icons.help_outline, color: Colors.blue, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'How to get your private key from MetaMask',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildHowToStep('1', 'Open MetaMask app or extension'),
          _buildHowToStep('2', 'Tap on the menu (three dots)'),
          _buildHowToStep('3', 'Select "Account Details"'),
          _buildHowToStep('4', 'Tap "Export Private Key"'),
          _buildHowToStep('5', 'Enter your MetaMask password'),
          _buildHowToStep('6', 'Copy the private key and paste here'),
        ],
      ),
    );
  }

  Widget _buildHowToStep(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Wallet Dashboard Screen (placeholder - you'll expand this)
class WalletDashboardScreen extends StatelessWidget {
  const WalletDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Wallet Dashboard - Coming Soon'),
      ),
    );
  }
}