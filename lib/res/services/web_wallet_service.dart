import 'dart:typed_data'; // ADD THIS
import 'package:flutter/foundation.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../utils/app_config.dart';

class Web3WalletService extends ChangeNotifier {
  Web3Client? _client;
  EthPrivateKey? _credentials;
  EthereumAddress? _address;
  bool _isConnected = false;
  String? _currentNetwork;

  // Secure storage for private key
  final _secureStorage = const FlutterSecureStorage();
  static const String _privateKeyKey = 'wallet_private_key';
  static const String _networkKey = 'selected_network';

  // Convert EthereumAddress to String manually
  String? get address => _address?.toString();
  bool get isConnected => _isConnected;
  String? get currentNetwork => _currentNetwork;
  EthereumAddress? get ethereumAddress => _address;

  /// Initialize the service and check for saved wallet
  Future<void> initialize() async {
    debugPrint('🔧 [Web3Wallet] Initializing...');

    try {
      // Load saved network
      final prefs = await SharedPreferences.getInstance();
      _currentNetwork = prefs.getString(_networkKey) ?? AppConfig.defaultNetwork;

      // Initialize Web3 client
      _initializeClient(_currentNetwork!);

      // Check for saved private key
      final savedKey = await _secureStorage.read(key: _privateKeyKey);
      if (savedKey != null && savedKey.isNotEmpty) {
        await _loadWalletFromPrivateKey(savedKey);
        debugPrint('✅ [Web3Wallet] Auto-loaded saved wallet');
      }

      debugPrint('✅ [Web3Wallet] Service initialized');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Initialization error: $e');
      rethrow;
    }
  }

  void _initializeClient(String network) {
    final rpcUrl = AppConfig.getRpcUrl(network);
    _client = Web3Client(rpcUrl, http.Client());
    debugPrint('🌐 [Web3Wallet] Client initialized for $network');
  }

  /// Import wallet using private key
  Future<void> importWalletFromPrivateKey(String privateKey, {bool saveKey = true}) async {
    try {
      debugPrint('🔐 [Web3Wallet] Importing wallet from private key...');

      // Remove 0x prefix if present
      final cleanKey = privateKey.trim().toLowerCase().replaceFirst('0x', '');

      // Validate private key length (64 hex characters)
      if (cleanKey.length != 64) {
        throw Exception('Invalid private key length. Must be 64 hex characters.');
      }

      // Create credentials
      _credentials = EthPrivateKey.fromHex(cleanKey);
      _address = _credentials!.address;
      _isConnected = true;

      // Save to secure storage if requested
      if (saveKey) {
        await _secureStorage.write(key: _privateKeyKey, value: cleanKey);
        debugPrint('💾 [Web3Wallet] Private key saved to secure storage');
      }

      debugPrint('✅ [Web3Wallet] Wallet imported successfully');
      debugPrint('✅ Address: ${_address.toString()}');

      notifyListeners();
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Import error: $e');
      rethrow;
    }
  }

  /// Import wallet using mnemonic phrase (12/24 words)
  Future<void> importWalletFromMnemonic(String mnemonic, {bool saveKey = true}) async {
    try {
      debugPrint('🔐 [Web3Wallet] Importing wallet from mnemonic...');

      // Create credentials from mnemonic
      final credentials = await _generateFromMnemonic(mnemonic);
      _credentials = credentials;
      _address = credentials.address;
      _isConnected = true;

      // Save private key if requested
      if (saveKey) {
        final privateKey = credentials.privateKey;
        final hexKey = bytesToHex(privateKey);
        await _secureStorage.write(key: _privateKeyKey, value: hexKey);
        debugPrint('💾 [Web3Wallet] Private key saved to secure storage');
      }

      debugPrint('✅ [Web3Wallet] Wallet imported from mnemonic');
      debugPrint('✅ Address: ${_address.toString()}');

      notifyListeners();
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Mnemonic import error: $e');
      rethrow;
    }
  }

  /// Generate wallet from mnemonic
  Future<EthPrivateKey> _generateFromMnemonic(String mnemonic) async {
    // Note: web3dart doesn't have built-in mnemonic support
    // You'll need to use bip39 package for this
    // For now, this is a placeholder
    throw UnimplementedError('Please use private key import or add bip39 package for mnemonic support');
  }

  /// Load wallet from saved private key
  Future<void> _loadWalletFromPrivateKey(String privateKey) async {
    try {
      _credentials = EthPrivateKey.fromHex(privateKey);
      _address = _credentials!.address;
      _isConnected = true;
    } catch (e) {
      debugPrint('⚠️ [Web3Wallet] Failed to load saved wallet: $e');
      await _secureStorage.delete(key: _privateKeyKey);
    }
  }

  /// Get wallet balance
  Future<EtherAmount> getBalance() async {
    if (!_isConnected || _address == null || _client == null) {
      throw Exception('Wallet not connected');
    }

    try {
      final balance = await _client!.getBalance(_address!);
      debugPrint('💰 [Web3Wallet] Balance: ${balance.getValueInUnit(EtherUnit.ether)} ETH');
      return balance;
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Balance error: $e');
      rethrow;
    }
  }

  /// Get balance in specific unit
  Future<String> getBalanceInEther() async {
    final balance = await getBalance();
    return balance.getValueInUnit(EtherUnit.ether).toStringAsFixed(4);
  }

  /// Send ETH transaction
  Future<String> sendTransaction({
    required String toAddress,
    required String amountInEther,
    String? data,
    int? customGasLimit,
    EtherAmount? customGasPrice,
  }) async {
    if (!_isConnected || _credentials == null || _client == null) {
      throw Exception('Wallet not connected');
    }

    try {
      debugPrint('📤 [Web3Wallet] Sending transaction...');
      debugPrint('To: $toAddress');
      debugPrint('Amount: $amountInEther ETH');

      final amount = EtherAmount.fromBigInt(
        EtherUnit.ether,
        BigInt.from(double.parse(amountInEther) * 1e18),
      );

      final transaction = Transaction(
        to: EthereumAddress.fromHex(toAddress),
        value: amount,
        data: data != null ? hexToBytes(data) : null,
        maxGas: customGasLimit,
        gasPrice: customGasPrice,
      );

      final chainId = await _getChainId();

      final txHash = await _client!.sendTransaction(
        _credentials!,
        transaction,
        chainId: chainId,
      );

      debugPrint('✅ [Web3Wallet] Transaction sent!');
      debugPrint('✅ Hash: $txHash');

      return txHash;
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Transaction error: $e');
      rethrow;
    }
  }

  /// Sign a message
  Future<String> signMessage(String message) async {
    if (!_isConnected || _credentials == null) {
      throw Exception('Wallet not connected');
    }

    try {
      debugPrint('✍️ [Web3Wallet] Signing message...');

      // Encode the message with Ethereum prefix
      final messageBytes = Uint8List.fromList(utf8.encode(message));
      final prefix = '\x19Ethereum Signed Message:\n${message.length}';
      final prefixBytes = Uint8List.fromList(utf8.encode(prefix));

      // Concatenate prefix + message
      final payload = Uint8List.fromList([...prefixBytes, ...messageBytes]);

      // Use signToSignature to get MsgSignature object
      final msgSignature = await _credentials!.signToEcSignature(payload);

      // Convert MsgSignature to hex format (r + s + v)
      final r = msgSignature.r.toRadixString(16).padLeft(64, '0');
      final s = msgSignature.s.toRadixString(16).padLeft(64, '0');
      final v = msgSignature.v.toRadixString(16).padLeft(2, '0');

      final hexSignature = '0x$r$s$v';

      debugPrint('✅ [Web3Wallet] Message signed');
      return hexSignature;
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Sign error: $e');
      rethrow;
    }
  }

  /// Get current gas price
  Future<EtherAmount> getGasPrice() async {
    if (_client == null) {
      throw Exception('Client not initialized');
    }

    try {
      final gasPrice = await _client!.getGasPrice();
      debugPrint('⛽ [Web3Wallet] Gas price: ${gasPrice.getValueInUnit(EtherUnit.gwei)} Gwei');
      return gasPrice;
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Gas price error: $e');
      rethrow;
    }
  }

  /// Estimate gas for transaction
  Future<BigInt> estimateGas({
    required String toAddress,
    String? value,
    String? data,
  }) async {
    if (_client == null || _address == null) {
      throw Exception('Wallet not connected');
    }

    try {
      final transaction = Transaction(
        from: _address,
        to: EthereumAddress.fromHex(toAddress),
        value: value != null
            ? EtherAmount.fromBigInt(EtherUnit.wei, BigInt.parse(value))
            : EtherAmount.zero(),
        data: data != null ? hexToBytes(data) : null,
      );

      final gasEstimate = await _client!.estimateGas(
        sender: _address,
        to: EthereumAddress.fromHex(toAddress),
        value: transaction.value,
        data: transaction.data,
      );

      debugPrint('⛽ [Web3Wallet] Estimated gas: $gasEstimate');
      return gasEstimate;
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Gas estimation error: $e');
      rethrow;
    }
  }

  /// Get transaction receipt
  Future<TransactionReceipt?> getTransactionReceipt(String txHash) async {
    if (_client == null) {
      throw Exception('Client not initialized');
    }

    try {
      final receipt = await _client!.getTransactionReceipt(txHash);

      if (receipt != null) {
        debugPrint('📜 [Web3Wallet] Transaction receipt retrieved');
        debugPrint('Status: ${receipt.status == true ? "Success" : "Failed"}'); // FIX: Proper null check
      }

      return receipt;
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Receipt error: $e');
      rethrow;
    }
  }

  /// Get transaction by hash
  Future<TransactionInformation?> getTransaction(String txHash) async {
    if (_client == null) {
      throw Exception('Client not initialized');
    }

    try {
      final tx = await _client!.getTransactionByHash(txHash);

      if (tx != null) {
        debugPrint('📄 [Web3Wallet] Transaction retrieved');
      }

      return tx;
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Get transaction error: $e');
      rethrow;
    }
  }

  /// Switch network
  Future<void> switchNetwork(String network) async {
    try {
      debugPrint('🔄 [Web3Wallet] Switching to $network...');

      _currentNetwork = network;
      _initializeClient(network);

      // Save network preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_networkKey, network);

      debugPrint('✅ [Web3Wallet] Switched to $network');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Network switch error: $e');
      rethrow;
    }
  }

  /// Get chain ID
  Future<int> _getChainId() async {
    if (_client == null) {
      throw Exception('Client not initialized');
    }

    try {
      final chainId = await _client!.getChainId();
      return chainId.toInt();
    } catch (e) {
      debugPrint('⚠️ [Web3Wallet] Chain ID error, using default');
      return 1; // Default to Ethereum mainnet
    }
  }

  /// Get current block number
  Future<int> getBlockNumber() async {
    if (_client == null) {
      throw Exception('Client not initialized');
    }

    try {
      final blockNumber = await _client!.getBlockNumber();
      debugPrint('🔢 [Web3Wallet] Current block: $blockNumber');
      return blockNumber;
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Block number error: $e');
      rethrow;
    }
  }

  /// Check if wallet is saved
  Future<bool> hasStoredWallet() async {
    final key = await _secureStorage.read(key: _privateKeyKey);
    return key != null && key.isNotEmpty;
  }

  /// Disconnect and clear wallet
  Future<void> disconnect({bool deleteStoredKey = false}) async {
    try {
      debugPrint('🔌 [Web3Wallet] Disconnecting wallet...');

      _credentials = null;
      _address = null;
      _isConnected = false;

      if (deleteStoredKey) {
        await _secureStorage.delete(key: _privateKeyKey);
        debugPrint('🗑️ [Web3Wallet] Stored private key deleted');
      }

      debugPrint('✅ [Web3Wallet] Wallet disconnected');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Disconnect error: $e');
      rethrow;
    }
  }

  /// Export private key (use with caution!)
  Future<String> exportPrivateKey() async {
    if (_credentials == null) {
      throw Exception('No wallet connected');
    }

    debugPrint('⚠️ [Web3Wallet] Exporting private key - USE WITH CAUTION!');
    return bytesToHex(_credentials!.privateKey, include0x: true);
  }

  @override
  void dispose() {
    _client?.dispose();
    super.dispose();
  }
}