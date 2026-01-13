/*
import 'package:flutter/foundation.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../../utils/app_config.dart';

class MetaMaskService extends ChangeNotifier {
  Web3App? _web3App;
  String? _currentAddress;
  String? _currentChainId;
  bool _isConnected = false;
  SessionData? _session;
  Timer? _sessionPollTimer;
  bool _isWaitingForConnection = false;

  String? get currentAddress => _currentAddress;
  String? get currentChainId => _currentChainId;
  bool get isConnected => _isConnected;
  SessionData? get session => _session;

  Future initialize() async {
    debugPrint('🔧 [MetaMask] Starting initialization...');

    try {
      final projectId = AppConfig.walletConnectProjectId;
      debugPrint('🔧 [MetaMask] Project ID length: ${projectId.length}');

      if (projectId.isEmpty) {
        throw Exception('WalletConnect Project ID not configured');
      }

      debugPrint('🔧 [MetaMask] Creating Web3App instance...');

      // 🔥 FIX: Use your app's custom scheme
      _web3App = await Web3App.createInstance(
        projectId: projectId,
        metadata: const PairingMetadata(
          name: 'Infinite Wealth',
          description: 'Secure Investment Platform',
          url: 'https://infinitewealth.com',
          icons: ['https://infinitewealth.com/icon.png'],
          redirect: Redirect(
            native: 'infinitewealth://',
            universal: 'https://infinitewealth.com',
          ),
        ),
      );
      debugPrint('✅ [MetaMask] Web3App created with redirect: infinitewealth://');

      // Subscribe to events
      _web3App?.onSessionConnect.subscribe(_onSessionConnect);
      _web3App?.onSessionDelete.subscribe(_onSessionDelete);
      _web3App?.onSessionUpdate.subscribe(_onSessionUpdate);

      // Check existing sessions
      final sessions = _web3App?.sessions.getAll();
      debugPrint('🔧 [MetaMask] Found ${sessions?.length ?? 0} existing sessions');

      if (sessions != null && sessions.isNotEmpty) {
        _session = sessions.first;
        _updateSessionData(_session!);
      }

      debugPrint('✅ [MetaMask] Service initialized successfully');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('❌ [MetaMask] Initialization error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  void _startSessionPolling() {
    debugPrint('🔄 Starting session polling...');
    _isWaitingForConnection = true;

    int pollCount = 0;
    _sessionPollTimer?.cancel();

    _sessionPollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      pollCount++;

      if (pollCount > 60) {
        timer.cancel();
        _isWaitingForConnection = false;
        debugPrint('⏱️ Session polling timeout');
        return;
      }

      if (!_isWaitingForConnection) {
        timer.cancel();
        return;
      }

      try {
        final sessions = _web3App?.sessions.getAll();

        if (sessions != null && sessions.isNotEmpty) {
          final latestSession = sessions.first;

          if (_session == null || _session!.topic != latestSession.topic) {
            debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            debugPrint('✅ NEW SESSION DETECTED VIA POLLING!');
            debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

            _session = latestSession;
            _updateSessionData(_session!);
            _isWaitingForConnection = false;
            timer.cancel();

            debugPrint('✅ Wallet connected via polling: $_currentAddress');
            debugPrint('✅ Chain ID: $_currentChainId');
            return;
          }
        }

        if (pollCount % 5 == 0) {
          debugPrint('🔄 Still polling... attempt $pollCount/60');
        }
      } catch (e) {
        debugPrint('⚠️ Polling error: $e');
      }
    });
  }

  void _stopSessionPolling() {
    _sessionPollTimer?.cancel();
    _isWaitingForConnection = false;
    debugPrint('⏹️ Session polling stopped');
  }

  Future<Uri?> connect({bool useQR = false}) async {
    if (_web3App == null) {
      throw Exception('MetaMask service not initialized');
    }

    try {
      debugPrint('🔗 [MetaMask] Starting connection...');

      final ConnectResponse response = await _web3App!.connect(
        requiredNamespaces: {
          'eip155': RequiredNamespace(
            chains: AppConfig.supportedChains,
            methods: [
              'eth_sendTransaction',
              'eth_signTransaction',
              'eth_sign',
              'personal_sign',
              'eth_signTypedData',
            ],
            events: ['chainChanged', 'accountsChanged'],
          ),
        },
      );

      final Uri? uri = response.uri;
      if (uri == null) {
        throw Exception('Failed to generate WalletConnect URI');
      }

      if (!useQR) {
        final wcUri = uri.toString();

        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('🔗 WalletConnect URI Generated:');
        debugPrint('🔗 URI: $wcUri');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // 🔥 IMPROVED: Try multiple launch methods
        bool launched = false;

        // Method 1: MetaMask deep link with encoded URI
        try {
          final encoded = Uri.encodeComponent(wcUri);
          final metamaskUri = Uri.parse('metamask://wc?uri=$encoded');

          debugPrint('🔗 Trying Method 1: MetaMask deep link');
          debugPrint('🔗 URI: $metamaskUri');

          if (await canLaunchUrl(metamaskUri)) {
            await launchUrl(metamaskUri, mode: LaunchMode.externalApplication);
            launched = true;
            debugPrint('✅ Launched via MetaMask deep link');
          }
        } catch (e) {
          debugPrint('⚠️ Method 1 failed: $e');
        }

        // Method 2: MetaMask universal link (fallback)
        if (!launched) {
          try {
            final encoded = Uri.encodeComponent(wcUri);
            final universalLink = Uri.parse('https://metamask.app.link/wc?uri=$encoded');

            debugPrint('🔗 Trying Method 2: Universal link');
            debugPrint('🔗 URI: $universalLink');

            await launchUrl(universalLink, mode: LaunchMode.externalApplication);
            launched = true;
            debugPrint('✅ Launched via universal link');
          } catch (e) {
            debugPrint('⚠️ Method 2 failed: $e');
          }
        }

        if (!launched) {
          throw Exception('Failed to launch MetaMask app');
        }

        debugPrint('⏳ MetaMask opened - waiting for user approval...');
        debugPrint('💡 Please approve the connection in MetaMask');
        debugPrint('💡 Then return to this app (MetaMask should auto-redirect)');

        // Start polling immediately
        _startSessionPolling();

        // Wait for session with extended timeout
        try {
          _session = await response.session.future.timeout(
            const Duration(minutes: 3),
            onTimeout: () {
              // Check if polling found the session
              if (_session != null && _isConnected) {
                debugPrint('✅ Session found via polling before timeout');
                return _session!;
              }

              // Give user helpful message
              throw Exception(
                  'Connection timeout. Did you approve in MetaMask? '
                      'If yes, please return to this app.'
              );
            },
          );

          _stopSessionPolling();

          if (_session != null) {
            _updateSessionData(_session!);
            debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            debugPrint('✅ CONNECTION SUCCESSFUL!');
            debugPrint('✅ Address: $_currentAddress');
            debugPrint('✅ Chain: $_currentChainId');
            debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          }

          return uri;
        } catch (e) {
          _stopSessionPolling();

          // Final check if we got connected via polling
          if (_isConnected && _session != null) {
            debugPrint('✅ Connected via polling despite timeout');
            return uri;
          }

          debugPrint('❌ Connection failed: $e');
          rethrow;
        }
      } else {
        // QR Code flow
        _waitForQRSession(response.session.future);
        return uri;
      }
    } catch (e) {
      _stopSessionPolling();
      debugPrint('❌ Connection error: $e');
      rethrow;
    }
  }

  Future<void> _waitForQRSession(Future<SessionData> sessionFuture) async {
    try {
      _session = await sessionFuture.timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw Exception('QR code scan timeout'),
      );

      if (_session != null) {
        _updateSessionData(_session!);
        debugPrint('✅ QR connected: $_currentAddress');
      }
    } catch (e) {
      debugPrint('❌ QR error: $e');
      rethrow;
    }
  }

  Future disconnect() async {
    if (_web3App == null || _session == null) {
      return;
    }

    try {
      _stopSessionPolling();

      await _web3App!.disconnectSession(
        topic: _session!.topic,
        reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
      );
      _clearSession();
      debugPrint('✅ Wallet disconnected');
    } catch (e) {
      debugPrint('❌ Disconnect error: $e');
      _clearSession();
      rethrow;
    }
  }

  Future sendTransaction({
    required String to,
    required String value,
    String? data,
    int? chainId,
  }) async {
    if (_web3App == null || _session == null || _currentAddress == null) {
      throw Exception('Not connected to MetaMask');
    }

    try {
      final selectedChainId = chainId ?? int.parse(_currentChainId ?? '1');

      final result = await _web3App!.request(
        topic: _session!.topic,
        chainId: 'eip155:$selectedChainId',
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [
            {
              'from': _currentAddress,
              'to': to,
              'value': '0x${BigInt.parse(value).toRadixString(16)}',
              if (data != null) 'data': data,
            }
          ],
        ),
      );

      debugPrint('✅ Transaction sent: $result');
      return result.toString();
    } catch (e) {
      debugPrint('❌ Transaction error: $e');
      rethrow;
    }
  }

  Future signMessage(String message) async {
    if (_web3App == null || _session == null || _currentAddress == null) {
      throw Exception('Not connected to MetaMask');
    }

    try {
      final result = await _web3App!.request(
        topic: _session!.topic,
        chainId: 'eip155:${_currentChainId ?? "1"}',
        request: SessionRequestParams(
          method: 'personal_sign',
          params: [message, _currentAddress],
        ),
      );

      debugPrint('✅ Message signed');
      return result.toString();
    } catch (e) {
      debugPrint('❌ Sign error: $e');
      rethrow;
    }
  }

  Future getBalance({String? network}) async {
    if (_currentAddress == null) {
      throw Exception('No wallet connected');
    }

    try {
      final rpcUrl = AppConfig.getRpcUrl(network ?? AppConfig.defaultNetwork);

      if (AppConfig.infuraProjectId.isEmpty) {
        throw Exception('Infura Project ID not configured');
      }

      final client = Web3Client(rpcUrl, http.Client());
      final balance = await client.getBalance(
        EthereumAddress.fromHex(_currentAddress!),
      );

      await client.dispose();
      debugPrint('💰 Balance: ${balance.getValueInUnit(EtherUnit.ether)} ETH');
      return balance;
    } catch (e) {
      debugPrint('❌ Balance error: $e');
      rethrow;
    }
  }

  Future switchChain(int chainId) async {
    if (_web3App == null || _session == null) {
      throw Exception('Not connected to MetaMask');
    }

    try {
      await _web3App!.request(
        topic: _session!.topic,
        chainId: 'eip155:$chainId',
        request: SessionRequestParams(
          method: 'wallet_switchEthereumChain',
          params: [
            {'chainId': '0x${chainId.toRadixString(16)}'}
          ],
        ),
      );

      _currentChainId = chainId.toString();
      notifyListeners();
      debugPrint('✅ Switched to chain: $chainId');
    } catch (e) {
      debugPrint('❌ Switch chain error: $e');
      rethrow;
    }
  }

  void _onSessionConnect(SessionConnect? event) {
    debugPrint('');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔔 SESSION CONNECT EVENT FIRED!');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (event?.session != null) {
      _session = event!.session;
      _updateSessionData(_session!);
      _stopSessionPolling();

      debugPrint('✅ Address: $_currentAddress');
      debugPrint('✅ Chain: $_currentChainId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      notifyListeners();
    }
  }

  void _onSessionDelete(SessionDelete? event) {
    _clearSession();
    _stopSessionPolling();
    debugPrint('🔔 Session deleted');
  }

  void _onSessionUpdate(SessionUpdate? event) {
    if (event != null && _web3App != null) {
      try {
        final updatedSession = _web3App!.sessions.get(event.topic);
        if (updatedSession != null) {
          _session = updatedSession;
          _updateSessionData(_session!);
          debugPrint('🔔 Session updated');
        }
      } catch (e) {
        debugPrint('⚠️ Failed to get updated session: $e');
      }
    }
  }

  void _updateSessionData(SessionData session) {
    final namespace = session.namespaces['eip155'];
    if (namespace != null && namespace.accounts.isNotEmpty) {
      final account = namespace.accounts.first;
      final parts = account.split(':');
      if (parts.length >= 3) {
        _currentAddress = parts.last;
        _currentChainId = parts[1];
        _isConnected = true;
        notifyListeners();
      }
    }
  }

  void _clearSession() {
    _session = null;
    _currentAddress = null;
    _currentChainId = null;
    _isConnected = false;
    _stopSessionPolling();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopSessionPolling();
    _web3App?.onSessionConnect.unsubscribe(_onSessionConnect);
    _web3App?.onSessionDelete.unsubscribe(_onSessionDelete);
    _web3App?.onSessionUpdate.unsubscribe(_onSessionUpdate);
    super.dispose();
  }
}*/
