import 'package:flutter/foundation.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_config.dart';

class MetaMaskService extends ChangeNotifier {
  Web3App? _web3App;
  String? _currentAddress;
  String? _currentChainId;
  bool _isConnected = false;
  SessionData? _session;

  String? get currentAddress => _currentAddress;
  String? get currentChainId => _currentChainId;
  bool get isConnected => _isConnected;
  SessionData? get session => _session;

  // Initialize WalletConnect
  Future initialize() async {
    debugPrint('🔍 [MetaMask] Starting initialization...');

    try {
      debugPrint('🔍 [MetaMask] Getting project ID from config...');
      final projectId = AppConfig.walletConnectProjectId;
      debugPrint('🔍 [MetaMask] Project ID length: ${projectId.length}');

      if (projectId.isEmpty) {
        debugPrint('❌ [MetaMask] Project ID is empty!');
        throw Exception('WalletConnect Project ID not configured. Please add it to .env file');
      }

      debugPrint('🔍 [MetaMask] Creating Web3App instance...');
      _web3App = await Web3App.createInstance(
        projectId: projectId,
        metadata: const PairingMetadata(
          name: 'Infinite Wealth',
          description: 'Secure Investment Platform',
          url: 'https://infinitewealth.com',
          icons: ['https://infinitewealth.com/icon.png'],
        ),
      );
      debugPrint('🔍 [MetaMask] Web3App instance created successfully');

      debugPrint('🔍 [MetaMask] Subscribing to events...');
      _web3App?.onSessionConnect.subscribe(_onSessionConnect);
      _web3App?.onSessionDelete.subscribe(_onSessionDelete);
      _web3App?.onSessionUpdate.subscribe(_onSessionUpdate);
      debugPrint('🔍 [MetaMask] Event subscriptions completed');

      debugPrint('🔍 [MetaMask] Checking for existing sessions...');
      final sessions = _web3App?.sessions.getAll();
      debugPrint('🔍 [MetaMask] Found ${sessions?.length ?? 0} existing sessions');

      if (sessions != null && sessions.isNotEmpty) {
        _session = sessions.first;
        _updateSessionData(_session!);
        debugPrint('🔍 [MetaMask] Restored existing session');
      }

      debugPrint('✅ [MetaMask] Service initialized successfully');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('❌ [MetaMask] Initialization error: $e');
      debugPrint('❌ [MetaMask] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Connect to MetaMask
  Future connect() async {  // ADD  ✅
    if (_web3App == null) {
      throw Exception('MetaMask service not initialized. Call initialize() first.');
    }

    try {
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

      final String metamaskUrl = 'metamask://wc?uri=${Uri.encodeComponent(uri.toString())}';

      debugPrint('🔗 Connecting to MetaMask...');

      try {
        final canLaunch = await canLaunchUrl(Uri.parse(metamaskUrl));
        if (canLaunch) {
          await launchUrl(
            Uri.parse(metamaskUrl),
            mode: LaunchMode.externalApplication,
          );
          debugPrint('✅ MetaMask app opened');
        } else {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          debugPrint('⚠️ Opened WalletConnect modal (MetaMask app not found)');
        }
      } catch (launchError) {
        debugPrint('⚠️ Failed to launch URL: $launchError');
      }

      _session = await response.session.future.timeout(
        const Duration(minutes: 3),
        onTimeout: () {
          throw Exception('Connection timeout. Please try again and approve in MetaMask app.');
        },
      );

      if (_session != null) {
        _updateSessionData(_session!);
        debugPrint('✅ Wallet connected: $_currentAddress');
      }
    } catch (e) {
      debugPrint('❌ MetaMask connection error: $e');
      rethrow;
    }
  }

  // Disconnect from MetaMask
  Future disconnect() async {
    if (_web3App == null || _session == null) {
      debugPrint('⚠️ No active session to disconnect');
      return;
    }

    try {
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

  // Send transaction
  Future sendTransaction({  // ADD  ✅
    required String to,
    required String value,
    String? data,
    int? chainId,
  }) async {
    if (_web3App == null || _session == null || _currentAddress == null) {
      throw Exception('Not connected to MetaMask. Please connect first.');
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
      debugPrint('❌ Send transaction error: $e');
      rethrow;
    }
  }

  // Sign message
  Future signMessage(String message) async {  // ADD  ✅
    if (_web3App == null || _session == null || _currentAddress == null) {
      throw Exception('Not connected to MetaMask. Please connect first.');
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
      debugPrint('❌ Sign message error: $e');
      rethrow;
    }
  }

  // Get balance - FIXED return type ✅
  Future getBalance({String? network}) async {
    if (_currentAddress == null) {
      throw Exception('No wallet connected');
    }

    try {
      final rpcUrl = AppConfig.getRpcUrl(network ?? AppConfig.defaultNetwork);

      if (AppConfig.infuraProjectId.isEmpty) {
        throw Exception('Infura Project ID not configured. Please add it to .env file');
      }

      final client = Web3Client(rpcUrl, http.Client());

      final balance = await client.getBalance(
        EthereumAddress.fromHex(_currentAddress!),
      );

      await client.dispose();
      debugPrint('💰 Balance: ${balance.getValueInUnit(EtherUnit.ether)} ETH');
      return balance;
    } catch (e) {
      debugPrint('❌ Get balance error: $e');
      rethrow;
    }
  }

  // Switch chain
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
    if (event?.session != null) {
      _session = event!.session;
      _updateSessionData(_session!);
      debugPrint('📡 Session connected event');
    }
  }

  void _onSessionDelete(SessionDelete? event) {
    _clearSession();
    debugPrint('📡 Session deleted event');
  }

  void _onSessionUpdate(SessionUpdate? event) {
    if (event != null && _web3App != null) {
      try {
        final updatedSession = _web3App!.sessions.get(event.topic);
        if (updatedSession != null) {
          _session = updatedSession;
          _updateSessionData(_session!);
          debugPrint('📡 Session updated event');
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
    notifyListeners();
  }

  @override
  void dispose() {
    _web3App?.onSessionConnect.unsubscribe(_onSessionConnect);
    _web3App?.onSessionDelete.unsubscribe(_onSessionDelete);
    _web3App?.onSessionUpdate.unsubscribe(_onSessionUpdate);
    super.dispose();
  }
}