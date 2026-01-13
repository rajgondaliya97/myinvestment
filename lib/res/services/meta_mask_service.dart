/*
import 'package:flutter/foundation.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../../utils/app_config.dart';

class MetaMaskService extends ChangeNotifier {
  ReownWalletKit? _walletKit;
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

  Future<void> initialize() async {
    debugPrint('🔧 [MetaMask] Starting initialization...');

    try {
      final projectId = AppConfig.walletConnectProjectId;
      debugPrint('🔧 [MetaMask] Project ID length: ${projectId.length}');

      if (projectId.isEmpty) {
        throw Exception('WalletConnect Project ID not configured');
      }

      debugPrint('🔧 [MetaMask] Creating ReownWalletKit instance...');

      // Initialize Reown WalletKit
      _walletKit = ReownWalletKit(
        core: ReownCore(
          projectId: projectId,
        ),
        metadata: PairingMetadata(
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

      debugPrint('✅ [MetaMask] ReownWalletKit created');

      // Register supported chains and methods
      await _registerSupportedChains();

      // Subscribe to events
      _walletKit!.onSessionProposal.subscribe(_onSessionProposal);
      _walletKit!.onSessionConnect.subscribe(_onSessionConnect);
      _walletKit!.onSessionDelete.subscribe(_onSessionDelete);
      _walletKit!.onSessionRequest.subscribe(_onSessionRequest);

      // Check existing sessions
      final sessions = _walletKit!.sessions.getAll();
      debugPrint('🔧 [MetaMask] Found ${sessions.length} existing sessions');

      if (sessions.isNotEmpty) {
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

  Future<void> _registerSupportedChains() async {
    try {
      // Register EVM chains and methods
      for (final chain in AppConfig.supportedChains) {
        final chainId = chain.split(':').last;

        // Register the chain with supported methods
        _walletKit!.registerEventEmitter(
          chainId: chain,
          event: 'chainChanged',
        );

        _walletKit!.registerEventEmitter(
          chainId: chain,
          event: 'accountsChanged',
        );
      }

      debugPrint('✅ [MetaMask] Registered supported chains and methods');
    } catch (e) {
      debugPrint('⚠️ [MetaMask] Error registering chains: $e');
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
        final sessions = _walletKit?.sessions.getAll();

        if (sessions != null && sessions.isNotEmpty) {
          final latestSession = sessions.first;

          if (_session == null || _session!.topic != latestSession.topic) {
            debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            debugPrint('✅ NEW SESSION DETECTED VIA POLLING!');
            debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

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

  Future<String?> connect() async {
    if (_walletKit == null) {
      throw Exception('MetaMask service not initialized');
    }

    try {
      debugPrint('🔗 [MetaMask] Starting connection...');

      // Pair with the dapp (this will generate a URI)
      final pairingUri = await _walletKit!.pair(uri: Uri.parse(''));

      if (pairingUri == null) {
        throw Exception('Failed to generate pairing URI');
      }

      final wcUri = pairingUri.toString();

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔗 WalletConnect URI Generated:');
      debugPrint('🔗 URI: $wcUri');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Try multiple launch methods
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

      // Start polling for session
      _startSessionPolling();

      return wcUri;
    } catch (e) {
      _stopSessionPolling();
      debugPrint('❌ Connection error: $e');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_walletKit == null || _session == null) {
      return;
    }

    try {
      _stopSessionPolling();

      await _walletKit!.disconnectSession(
        topic: _session!.topic,
        reason: Errors.getSdkError(Errors.USER_DISCONNECTED).toSignError(),
      );
      _clearSession();
      debugPrint('✅ Wallet disconnected');
    } catch (e) {
      debugPrint('❌ Disconnect error: $e');
      _clearSession();
      rethrow;
    }
  }

  Future<String> sendTransaction({
    required String to,
    required String value,
    String? data,
    int? chainId,
  }) async {
    if (_walletKit == null || _session == null || _currentAddress == null) {
      throw Exception('Not connected to MetaMask');
    }

    try {
      final selectedChainId = chainId ?? int.parse(_currentChainId ?? '1');

      final result = await _walletKit!.request(
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

  Future<String> signMessage(String message) async {
    if (_walletKit == null || _session == null || _currentAddress == null) {
      throw Exception('Not connected to MetaMask');
    }

    try {
      final result = await _walletKit!.request(
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

  Future<EtherAmount> getBalance({String? network}) async {
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

  Future<void> switchChain(int chainId) async {
    if (_walletKit == null || _session == null) {
      throw Exception('Not connected to MetaMask');
    }

    try {
      await _walletKit!.request(
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

  void _onSessionProposal(SessionProposalEvent? event) async {
    if (event == null || _walletKit == null) return;

    debugPrint('');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔔 SESSION PROPOSAL RECEIVED!');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      // Auto-approve the session with generated namespaces
      final namespaces = event.params.generatedNamespaces;

      if (namespaces != null) {
        await _walletKit!.approveSession(
          id: event.id,
          namespaces: namespaces,
        );
        debugPrint('✅ Session auto-approved');
      } else {
        debugPrint('❌ No namespaces generated');
      }
    } catch (e) {
      debugPrint('❌ Error approving session: $e');
    }
  }

  void _onSessionConnect(SessionConnect? event) {
    debugPrint('');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔔 SESSION CONNECT EVENT FIRED!');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (event?.session != null) {
      _session = event!.session;
      _updateSessionData(_session!);
      _stopSessionPolling();

      debugPrint('✅ Address: $_currentAddress');
      debugPrint('✅ Chain: $_currentChainId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      notifyListeners();
    }
  }

  void _onSessionDelete(SessionDelete? event) {
    _clearSession();
    _stopSessionPolling();
    debugPrint('🔔 Session deleted');
  }

  void _onSessionRequest(SessionRequestEvent? event) {
    if (event == null || _walletKit == null) return;

    debugPrint('🔔 Session request received: ${event.method}');

    // You can handle specific requests here if needed
    // For now, they'll be handled by the request() method
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
    _walletKit?.onSessionProposal.unsubscribe(_onSessionProposal);
    _walletKit?.onSessionConnect.unsubscribe(_onSessionConnect);
    _walletKit?.onSessionDelete.unsubscribe(_onSessionDelete);
    _walletKit?.onSessionRequest.unsubscribe(_onSessionRequest);
    super.dispose();
  }
}*/
