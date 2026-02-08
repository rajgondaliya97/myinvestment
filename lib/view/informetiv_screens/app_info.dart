import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:myinvestment/res/app_widget/custom_app_bar.dart';
import '../../utils/app_color.dart';

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _loadingProgress = 0.0;
            });
            print('📄 Page started loading: $url');
          },
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100;
            });
            print('⏳ Loading progress: $progress%');
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = false;
            });
            print('✅ Page finished loading: $url');

            // Inject JavaScript to detect login button clicks
            await _injectLoginDetector();
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ Web resource error: ${error.description}');
            _showErrorSnackBar('Error loading page: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🔗 Navigation request: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'LoginChannel',
        onMessageReceived: (JavaScriptMessage message) {
          print('🔐 LOGIN BUTTON CLICKED!');
          print('📝 Message: ${message.message}');
          _handleLoginClick(message.message);
        },
      )
      ..loadRequest(Uri.parse('https://infinitewealth.uk'));
  }

  Future<void> _injectLoginDetector() async {
    // JavaScript code to detect login button clicks
    const String jsCode = '''
      (function() {
        console.log('🔍 Injecting login detector...');
        
        // Function to handle clicks
        function handleClick(event) {
          var element = event.target;
          var text = element.textContent || element.innerText || '';
          var href = element.href || '';
          var className = element.className || '';
          var id = element.id || '';
          
          console.log('👆 Clicked element:', {
            text: text,
            href: href,
            className: className,
            id: id,
            tagName: element.tagName
          });
          
          // Check if it's a login-related element
          var isLoginButton = false;
          var lowerText = text.toLowerCase();
          var lowerClass = className.toLowerCase();
          var lowerId = id.toLowerCase();
          var lowerHref = href.toLowerCase();
          
          if (lowerText.includes('login') || 
              lowerText.includes('log in') || 
              lowerText.includes('sign in') || 
              lowerText.includes('signin') ||
              lowerClass.includes('login') ||
              lowerId.includes('login') ||
              lowerHref.includes('login') ||
              lowerHref.includes('signin')) {
            isLoginButton = true;
          }
          
          if (isLoginButton) {
            console.log('✅ LOGIN BUTTON DETECTED!');
            var data = JSON.stringify({
              text: text.trim(),
              href: href,
              className: className,
              id: id,
              timestamp: new Date().toISOString()
            });
            
            // Send message to Flutter
            if (window.LoginChannel) {
              window.LoginChannel.postMessage(data);
            }
          }
        }
        
        // Add click listener to document
        document.addEventListener('click', handleClick, true);
        
        // Also monitor specific login elements
        var loginLinks = document.querySelectorAll('a[href*="login"], a[href*="signin"], button[class*="login"], button[id*="login"]');
        console.log('🔍 Found ' + loginLinks.length + ' potential login elements');
        
        loginLinks.forEach(function(link) {
          link.addEventListener('click', function(e) {
            console.log('🎯 Direct login element clicked!');
            handleClick(e);
          });
        });
        
        console.log('✅ Login detector injected successfully!');
      })();
    ''';

    try {
      await _controller.runJavaScript(jsCode);
      print('✅ JavaScript injected successfully');
    } catch (e) {
      print('❌ Error injecting JavaScript: $e');
    }
  }

  void _handleLoginClick(String message) {
    print('\n═══════════════════════════════════════');
    print('🔐 LOGIN BUTTON CLICK DETECTED!');
    print('═══════════════════════════════════════');
    print('📝 Raw Message: $message');
    print('⏰ Timestamp: ${DateTime.now()}');
    print('═══════════════════════════════════════\n');

    // Parse the JSON message
    try {
      // Show a dialog or snackbar
      _showLoginDetectedDialog(message);
    } catch (e) {
      print('❌ Error parsing message: $e');
    }
  }

  void _showLoginDetectedDialog(String details) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.login_rounded,
              color: AppColor.primaryColor,
              size: 28.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              'Login Detected',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.secondaryPrimaryColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Login button clicked!',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.grey500,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                details,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontFamily: 'monospace',
                  color: AppColor.secondaryPrimaryColor,
                ),
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppColor.primaryColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    // Also show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Login button click detected!',
                style: TextStyle(fontSize: 13.sp),
              ),
            ),
          ],
        ),
        backgroundColor: AppColor.primaryColor,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 13.sp),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  Future<void> _refreshPage() async {
    await _controller.reload();
  }

  Future<bool> _goBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _goBack,
      child: Scaffold(
        body: Stack(
          children: [
            // WebView
            WebViewWidget(controller: _controller),

            // Loading indicator
            if (_isLoading)
              Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColor.primaryColor,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Loading Infinite Wealth UK...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColor.grey500,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: LinearProgressIndicator(
                        value: _loadingProgress,
                        backgroundColor: AppColor.grey300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColor.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Back button overlay (bottom left)
            Positioned(
              left: 16.w,
              bottom: 30.h,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    if (await _goBack()) {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColor.secondaryPrimaryColor.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColor.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            ),

            // Refresh button overlay (bottom right)
            Positioned(
              right: 16.w,
              bottom: 30.h,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _refreshPage,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.refresh,
                      color: AppColor.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}