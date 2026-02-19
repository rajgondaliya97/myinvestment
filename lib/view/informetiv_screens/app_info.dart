import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myinvestment/view/auth/screen/auth_wrapper.dart';
import 'package:myinvestment/view/auth/screen/login_screen.dart';
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
  bool _isNavigatingToLogin = false; // Guard: prevent duplicate navigation

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

            // Intercept login page navigations — open app's login screen instead
            final uri = Uri.tryParse(request.url);
            if (uri != null) {
              final path = uri.path.toLowerCase();
              if (path.contains('login') || path.contains('signin')) {
                _navigateToLoginScreen();
                return NavigationDecision.prevent;
              }
            }

            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            final url = change.url ?? '';
            print('🔗 URL changed: $url');
            final uri = Uri.tryParse(url);
            if (uri != null) {
              final path = uri.path.toLowerCase();
              if (path.contains('login') || path.contains('signin')) {
                _navigateToLoginScreen();
              }
            }
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
      ..loadRequest(Uri.parse('https://infinitewealth.uk/?isapp=123456'));
  }

  Future<void> _injectLoginDetector() async {
    // JavaScript code to detect login button clicks and send to Flutter
    const String jsCode = '''
      (function() {
        if (window.__loginDetectorInjected) return;
        window.__loginDetectorInjected = true;
        console.log('🔍 Injecting login detector...');

        function getLoginData(element) {
          var text = (element.textContent || element.innerText || '').trim();
          var href = element.href || element.getAttribute('href') || '';
          var className = element.className || '';
          var id = element.id || '';

          var lowerText = text.toLowerCase();
          var lowerClass = (typeof className === 'string' ? className : '').toLowerCase();
          var lowerId = id.toLowerCase();
          var lowerHref = href.toLowerCase();

          var isLogin =
            lowerText === 'login' ||
            lowerText === 'log in' ||
            lowerText === 'sign in' ||
            lowerText === 'signin' ||
            lowerClass.includes('login') ||
            lowerId.includes('login') ||
            lowerHref.includes('/login') ||
            lowerHref.includes('/signin');

          return isLogin ? { text: text, href: href, className: className, id: id } : null;
        }

        function tryNotify(element) {
          // Walk up up to 3 levels to find the login anchor/button
          for (var i = 0; i < 4; i++) {
            if (!element || element === document.body) break;
            var data = getLoginData(element);
            if (data) {
              console.log('✅ LOGIN element found:', data);
              if (window.LoginChannel) {
                window.LoginChannel.postMessage(JSON.stringify(data));
              }
              return true;
            }
            element = element.parentElement;
          }
          return false;
        }

        document.addEventListener('click', function(e) {
          tryNotify(e.target);
        }, true);

        console.log('✅ Login detector injected');
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
    print('📝 Raw Message: $message');
    print('⏰ Timestamp: ${DateTime.now()}');
    print('═══════════════════════════════════════\n');

    // Parse message to extract any pre-filled email if passed from website
    String? prefillEmail;
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final href = (data['href'] as String? ?? '');
      final uri = Uri.tryParse(href);
      prefillEmail = uri?.queryParameters['email'];
    } catch (_) {}

    _navigateToLoginScreen(prefillEmail: prefillEmail);
  }

  /// Clear all WebView data — cookies, cache, localStorage
  Future<void> _clearWebViewData() async {
    try {
      // Clear cookies
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();
      print('🧹 WebView cookies cleared');

      // Clear cache and localStorage via JavaScript
      await _controller.runJavaScript('''
        try { localStorage.clear(); } catch(e) {}
        try { sessionStorage.clear(); } catch(e) {}
      ''');
      print('🧹 WebView localStorage/sessionStorage cleared');
    } catch (e) {
      print('⚠️ Error clearing WebView data: $e');
    }
  }

  /// Navigate to the app's native Login screen (guarded against duplicate calls)
  void _navigateToLoginScreen({String? prefillEmail}) {
    if (_isNavigatingToLogin || !mounted) return;
    _isNavigatingToLogin = true;

    // Clear WebView data before navigating to login
    _clearWebViewData().then((_) {
      if (!mounted) {
        _isNavigatingToLogin = false;
        return;
      }
      Navigator.of(context)
          .pushReplacement(
            MaterialPageRoute(
              builder: (_) => AuthWrapper(),
            ),
          )
          .then((_) => _isNavigatingToLogin = false);
    });
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