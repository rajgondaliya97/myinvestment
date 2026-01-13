import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

class DeepLinkHandler {
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _sub;
  static const platform = MethodChannel('com.infinite.wealth/deeplink');
  static Timer? _pollTimer;

  // 🔥 ADD: Callback for WalletConnect deep links
  static Function(Uri)? onWalletConnectCallback;

  static void initialize({Function(Uri)? onWalletConnect}) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔗 Initializing deep link handler...');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Store the callback
    onWalletConnectCallback = onWalletConnect;

    // Method 1: app_links package stream
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      debugPrint('🔗 [Method 1] Deep link via app_links stream: $uri');
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('❌ [Method 1] app_links stream error: $err');
    });

    // Method 2: Check initial link from app_links
    _checkInitialLink();

    // Method 3: Native MethodChannel listener
    _setupNativeListener();

    // Method 4: Polling as backup (stops after 10 seconds)
    _startPolling();

    debugPrint('✅ Deep link handler initialized with 4 methods');
  }

  static void _setupNativeListener() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onDeepLink') {
        final String? deepLink = call.arguments as String?;
        if (deepLink != null) {
          debugPrint('🔗 [Method 3] Deep link via Native MethodChannel: $deepLink');
          try {
            final uri = Uri.parse(deepLink);
            _handleDeepLink(uri);
          } catch (e) {
            debugPrint('❌ Failed to parse deep link: $e');
          }
        }
      }
    });
    debugPrint('✅ Native MethodChannel listener setup');
  }

  static void _startPolling() {
    int pollCount = 0;
    const maxPolls = 10;

    _pollTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      pollCount++;

      if (pollCount > maxPolls) {
        timer.cancel();
        debugPrint('⏹️ Stopped polling for deep links');
        return;
      }

      try {
        final uri = await _appLinks.getLatestLink();
        if (uri != null) {
          debugPrint('🔗 [Method 4] Deep link via polling: $uri');
          _handleDeepLink(uri);
        }
      } catch (e) {
        // Silent fail during polling
      }
    });

    debugPrint('✅ Polling started (will run for 10 seconds)');
  }

  static Future<void> _checkInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        debugPrint('🔗 [Method 2] Initial deep link via app_links: $uri');
        _handleDeepLink(uri);
        return;
      }

      final String? nativeLink = await platform.invokeMethod('getInitialLink');
      if (nativeLink != null) {
        debugPrint('🔗 [Method 2] Initial deep link via native: $nativeLink');
        final nativeUri = Uri.parse(nativeLink);
        _handleDeepLink(nativeUri);
        return;
      }

      debugPrint('ℹ️ No initial deep link found');
    } catch (e) {
      debugPrint('❌ Initial link check error: $e');
    }
  }

  static void _handleDeepLink(Uri uri) {
    debugPrint('');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🎯 DEEP LINK HANDLER TRIGGERED!');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔗 Scheme: ${uri.scheme}');
    debugPrint('🔗 Host: ${uri.host}');
    debugPrint('🔗 Path: ${uri.path}');
    debugPrint('🔗 Query: ${uri.query}');
    debugPrint('🔗 Fragment: ${uri.fragment}');
    debugPrint('🔗 Full URI: $uri');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('');

    if (uri.scheme == 'wc') {
      debugPrint('✅ WalletConnect callback detected!');
      debugPrint('✅ Notifying MetaMaskService...');
      // 🔥 CRITICAL: Notify the service
      onWalletConnectCallback?.call(uri);
    } else if (uri.scheme == 'infinitewealth') {
      debugPrint('✅ App-specific deep link detected');
      // 🔥 CRITICAL: Also check if it's a WalletConnect callback
      if (uri.host == 'com.infinite.wealth' || uri.host == 'wc') {
        debugPrint('✅ WalletConnect return detected!');
        onWalletConnectCallback?.call(uri);
      }
    } else {
      debugPrint('⚠️ Unknown deep link scheme: ${uri.scheme}');
    }
  }

  static void dispose() {
    _sub?.cancel();
    _pollTimer?.cancel();
    onWalletConnectCallback = null;
    debugPrint('🔗 Deep link handler disposed');
  }
}