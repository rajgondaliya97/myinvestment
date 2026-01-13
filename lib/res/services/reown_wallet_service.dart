// ============================================
// FIXED reown_wallet_service.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_config.dart';

class ReownWalletService extends ChangeNotifier {
  ReownAppKitModal? _appKitModal;
  bool _isInitialized = false;

  bool get isConnected => _appKitModal?.isConnected ?? false;
  String? get address => _appKitModal?.session?.address;
  String? get chainId => _appKitModal?.selectedChain?.chainId;
  ReownAppKitModal? get appKitModal => _appKitModal;

  // Initialize with BuildContext
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) {
      debugPrint('⚠️ [Reown] Already initialized');
      return;
    }

    try {
      debugPrint('🔧 [Reown] Starting initialization...');

      final projectId = AppConfig.walletConnectProjectId;

      if (projectId.isEmpty) {
        throw Exception('WalletConnect Project ID not configured');
      }

      // Create ReownAppKitModal instance
      _appKitModal = ReownAppKitModal(
        context: context,
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

      // 🔥 FIX: Just call init() with no parameters
      // The SDK handles chain configuration internally
      await _appKitModal!.init();

      // Listen to session events
      _appKitModal!.onModalConnect.subscribe(_onModalConnect);
      _appKitModal!.onModalDisconnect.subscribe(_onModalDisconnect);

      _isInitialized = true;
      debugPrint('✅ [Reown] Service initialized successfully');

      // Check if already connected
      if (_appKitModal!.isConnected) {
        debugPrint('✅ [Reown] Already connected: ${_appKitModal!.session?.address}');
        notifyListeners();
      }

    } catch (e, stackTrace) {
      debugPrint('❌ [Reown] Initialization error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Open the wallet selection modal
  Future<void> connect() async {
    if (_appKitModal == null) {
      throw Exception('Reown AppKit not initialized');
    }

    try {
      debugPrint('🔗 [Reown] Opening wallet modal...');
      await _appKitModal!.openModalView();
      debugPrint('✅ [Reown] Modal opened');
    } catch (e) {
      debugPrint('❌ [Reown] Connect error: $e');
      rethrow;
    }
  }

  // Disconnect wallet
  Future<void> disconnect() async {
    if (_appKitModal == null || !_appKitModal!.isConnected) {
      debugPrint('⚠️ [Reown] Not connected');
      return;
    }

    try {
      debugPrint('🔗 [Reown] Disconnecting...');
      await _appKitModal!.disconnect();
      debugPrint('✅ [Reown] Disconnected successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [Reown] Disconnect error: $e');
      rethrow;
    }
  }

  // Send transaction
  Future<String> sendTransaction({
    required String to,
    required String value,
    String? data,
  }) async {
    if (_appKitModal == null || !_appKitModal!.isConnected) {
      throw Exception('Wallet not connected');
    }

    try {
      debugPrint('📤 [Reown] Sending transaction...');

      final session = _appKitModal!.session;
      if (session == null) {
        throw Exception('No active session');
      }

      final result = await _appKitModal!.request(
        topic: session.topic,
        chainId: 'eip155:${_appKitModal!.selectedChain?.chainId ?? "1"}',
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [
            {
              'from': session.address,
              'to': to,
              'value': '0x${BigInt.parse(value).toRadixString(16)}',
              if (data != null) 'data': data,
            }
          ],
        ),
      );

      debugPrint('✅ [Reown] Transaction sent: $result');
      return result.toString();
    } catch (e) {
      debugPrint('❌ [Reown] Transaction error: $e');
      rethrow;
    }
  }

  // Sign message
  Future<String> signMessage(String message) async {
    if (_appKitModal == null || !_appKitModal!.isConnected) {
      throw Exception('Wallet not connected');
    }

    try {
      debugPrint('✏️ [Reown] Signing message...');

      final session = _appKitModal!.session;
      if (session == null) {
        throw Exception('No active session');
      }

      final result = await _appKitModal!.request(
        topic: session.topic,
        chainId: 'eip155:${_appKitModal!.selectedChain?.chainId ?? "1"}',
        request: SessionRequestParams(
          method: 'personal_sign',
          params: [message, session.address],
        ),
      );

      debugPrint('✅ [Reown] Message signed');
      return result.toString();
    } catch (e) {
      debugPrint('❌ [Reown] Sign error: $e');
      rethrow;
    }
  }

  // Get balance
  Future<EtherAmount> getBalance({String? network}) async {
    if (!isConnected || address == null) {
      throw Exception('Wallet not connected');
    }

    try {
      final rpcUrl = AppConfig.getRpcUrl(network ?? AppConfig.defaultNetwork);

      if (AppConfig.infuraProjectId.isEmpty) {
        throw Exception('Infura Project ID not configured');
      }

      final client = Web3Client(rpcUrl, http.Client());
      final balance = await client.getBalance(
        EthereumAddress.fromHex(address!),
      );

      await client.dispose();
      debugPrint('💰 [Reown] Balance: ${balance.getValueInUnit(EtherUnit.ether)} ETH');
      return balance;
    } catch (e) {
      debugPrint('❌ [Reown] Balance error: $e');
      rethrow;
    }
  }

  // Switch chain
  Future<void> switchChain(int chainId) async {
    if (_appKitModal == null || !_appKitModal!.isConnected) {
      throw Exception('Wallet not connected');
    }

    try {
      debugPrint('🔄 [Reown] Switching to chain: $chainId');

      final session = _appKitModal!.session;
      if (session == null) {
        throw Exception('No active session');
      }

      await _appKitModal!.request(
        topic: session.topic,
        chainId: 'eip155:$chainId',
        request: SessionRequestParams(
          method: 'wallet_switchEthereumChain',
          params: [
            {'chainId': '0x${chainId.toRadixString(16)}'}
          ],
        ),
      );

      debugPrint('✅ [Reown] Chain switched to: $chainId');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [Reown] Switch chain error: $e');
      rethrow;
    }
  }

  // Event handlers
  void _onModalConnect(ModalConnect? event) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔔 [Reown] MODAL CONNECTED!');
    debugPrint('✅ Address: ${event?.session.address}');
    debugPrint('✅ Topic: ${event?.session.topic}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    notifyListeners();
  }

  void _onModalDisconnect(ModalDisconnect? event) {
    debugPrint('🔔 [Reown] Modal disconnected');
    notifyListeners();
  }

  @override
  void dispose() {
    _appKitModal?.onModalConnect.unsubscribe(_onModalConnect);
    _appKitModal?.onModalDisconnect.unsubscribe(_onModalDisconnect);
    super.dispose();
  }
}