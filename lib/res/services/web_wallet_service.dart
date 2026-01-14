import 'dart:typed_data';
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

  // USDT Contract Addresses (UPDATED with correct addresses)
  static const Map<String, String> _usdtContractAddresses = {
    'ethereum': '0xdAC17F958D2ee523a2206206994597C13D831ec7', // Ethereum Mainnet USDT
    'bsc': '0x55d398326f99059fF775485246999027B3197955', // BSC USDT (Binance-Peg USDT)
    'polygon': '0xc2132D05D31c914a87C6611C10748AEb04B58e8F', // Polygon USDT
    'sepolia': '0x7169D38820dfd117C3FA1f22a697dBA58d90BA06', // Sepolia Testnet
    'goerli': '0x509Ee0d083DdF8AC028f2a56731412edD63223B9', // Goerli Testnet
  };

  // Token decimals per network
  static const Map<String, int> _usdtDecimals = {
    'ethereum': 6, // Ethereum USDT has 6 decimals
    'bsc': 18, // BSC USDT has 18 decimals
    'polygon': 6, // Polygon USDT has 6 decimals
    'sepolia': 6,
    'goerli': 6,
  };

  // ERC-20 ABI for balanceOf and decimals
  static const String _erc20Abi = '''
  [
    {
      "constant": true,
      "inputs": [{"name": "_owner", "type": "address"}],
      "name": "balanceOf",
      "outputs": [{"name": "balance", "type": "uint256"}],
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "decimals",
      "outputs": [{"name": "", "type": "uint8"}],
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "symbol",
      "outputs": [{"name": "", "type": "string"}],
      "type": "function"
    },
    {
      "constant": false,
      "inputs": [
        {"name": "_to", "type": "address"},
        {"name": "_value", "type": "uint256"}
      ],
      "name": "transfer",
      "outputs": [{"name": "", "type": "bool"}],
      "type": "function"
    }
  ]
  ''';

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

      debugPrint('📍 [Web3Wallet] Current Network: $_currentNetwork');

      // Initialize Web3 client
      _initializeClient(_currentNetwork!);

      // Check for saved private key
      final savedKey = await _secureStorage.read(key: _privateKeyKey);
      if (savedKey != null && savedKey.isNotEmpty) {
        await _loadWalletFromPrivateKey(savedKey);
        debugPrint('✅ [Web3Wallet] Auto-loaded saved wallet');
        debugPrint('📍 Address: ${_address?.toString()}');
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
    debugPrint('🌐 [Web3Wallet] RPC URL: $rpcUrl');
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

  /// Get wallet balance (ETH/BNB/Native token)
  Future<EtherAmount> getBalance() async {
    if (!_isConnected || _address == null || _client == null) {
      throw Exception('Wallet not connected');
    }

    try {
      final balance = await _client!.getBalance(_address!);
      final nativeSymbol = _getNativeSymbol(_currentNetwork!);
      debugPrint('💰 [Web3Wallet] Balance: ${balance.getValueInUnit(EtherUnit.ether)} $nativeSymbol');
      return balance;
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Balance error: $e');
      rethrow;
    }
  }

  String _getNativeSymbol(String network) {
    switch (network) {
      case 'ethereum':
        return 'ETH';
      case 'bsc':
        return 'BNB';
      case 'polygon':
        return 'MATIC';
      default:
        return 'ETH';
    }
  }

  /// Get balance in specific unit
  Future<String> getBalanceInEther() async {
    final balance = await getBalance();
    return balance.getValueInUnit(EtherUnit.ether).toStringAsFixed(4);
  }

  /// Get USDT balance for current network
  Future<String> getUsdtBalance() async {
    if (!_isConnected || _address == null || _client == null) {
      throw Exception('Wallet not connected');
    }

    try {
      final contractAddress = _usdtContractAddresses[_currentNetwork];
      if (contractAddress == null) {
        debugPrint('⚠️ [Web3Wallet] USDT not supported on $_currentNetwork');
        throw Exception('USDT not supported on $_currentNetwork');
      }

      final decimals = _usdtDecimals[_currentNetwork] ?? 6;

      debugPrint('🪙 [Web3Wallet] Getting USDT balance...');
      debugPrint('📍 Network: $_currentNetwork');
      debugPrint('📍 Contract: $contractAddress');
      debugPrint('📍 Decimals: $decimals');
      debugPrint('📍 Address: ${_address.toString()}');

      // Create contract instance
      final contract = DeployedContract(
        ContractAbi.fromJson(_erc20Abi, 'ERC20'),
        EthereumAddress.fromHex(contractAddress),
      );

      // Get balanceOf function
      final balanceFunction = contract.function('balanceOf');

      // Call the contract
      final result = await _client!.call(
        contract: contract,
        function: balanceFunction,
        params: [_address!],
      );

      // Parse balance
      final balance = result[0] as BigInt;

      debugPrint('📊 [Web3Wallet] Raw balance: $balance');

      // Convert to decimal based on network
      final divisor = BigInt.from(10).pow(decimals);
      final balanceInUsdt = balance / divisor;

      debugPrint('💵 [Web3Wallet] USDT Balance: $balanceInUsdt USDT');

      return balanceInUsdt.toStringAsFixed(2);
    } catch (e) {
      debugPrint('❌ [Web3Wallet] USDT balance error: $e');
      rethrow;
    }
  }

  /// Get ERC-20 token balance (generic)
  Future<String> getTokenBalance({
    required String contractAddress,
    int decimals = 18,
  }) async {
    if (!_isConnected || _address == null || _client == null) {
      throw Exception('Wallet not connected');
    }

    try {
      debugPrint('🪙 [Web3Wallet] Getting token balance for $contractAddress...');

      // Create contract instance
      final contract = DeployedContract(
        ContractAbi.fromJson(_erc20Abi, 'ERC20'),
        EthereumAddress.fromHex(contractAddress),
      );

      // Get balanceOf function
      final balanceFunction = contract.function('balanceOf');

      // Call the contract
      final result = await _client!.call(
        contract: contract,
        function: balanceFunction,
        params: [_address!],
      );

      // Parse balance
      final balance = result[0] as BigInt;
      final balanceInToken = balance / BigInt.from(10).pow(decimals);

      debugPrint('💰 [Web3Wallet] Token Balance: $balanceInToken');

      return balanceInToken.toStringAsFixed(decimals > 6 ? 6 : decimals);
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Token balance error: $e');
      rethrow;
    }
  }

  /// Send USDT
  Future<String> sendUsdt({
    required String toAddress,
    required String amount,
  }) async {
    if (!_isConnected || _credentials == null || _client == null) {
      throw Exception('Wallet not connected');
    }

    try {
      final contractAddress = _usdtContractAddresses[_currentNetwork];
      if (contractAddress == null) {
        throw Exception('USDT not supported on $_currentNetwork');
      }

      final decimals = _usdtDecimals[_currentNetwork] ?? 6;

      debugPrint('📤 [Web3Wallet] Sending USDT...');
      debugPrint('To: $toAddress');
      debugPrint('Amount: $amount USDT');
      debugPrint('Decimals: $decimals');

      // Create contract instance
      final contract = DeployedContract(
        ContractAbi.fromJson(_erc20Abi, 'ERC20'),
        EthereumAddress.fromHex(contractAddress),
      );

      // Get transfer function
      final transferFunction = contract.function('transfer');

      // Convert amount to smallest unit based on decimals
      final amountInSmallestUnit = BigInt.from(double.parse(amount) * pow(10, decimals));

      debugPrint('📊 Amount in smallest unit: $amountInSmallestUnit');

      // Send transaction
      final transaction = Transaction.callContract(
        contract: contract,
        function: transferFunction,
        parameters: [
          EthereumAddress.fromHex(toAddress),
          amountInSmallestUnit,
        ],
      );

      final chainId = await _getChainId();

      final txHash = await _client!.sendTransaction(
        _credentials!,
        transaction,
        chainId: chainId,
      );

      debugPrint('✅ [Web3Wallet] USDT sent!');
      debugPrint('✅ Hash: $txHash');

      return txHash;
    } catch (e) {
      debugPrint('❌ [Web3Wallet] USDT send error: $e');
      rethrow;
    }
  }

  /// Send native token (ETH/BNB) transaction
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
      debugPrint('Amount: $amountInEther ${_getNativeSymbol(_currentNetwork!)}');

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
      debugPrint('⚠️ [Web3Wallet] Chain ID error, using configured value');
      return AppConfig.getChainId(_currentNetwork ?? 'bsc');
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

  @override
  void dispose() {
    _client?.dispose();
    super.dispose();
  }
}

// Helper function for pow
num pow(num x, num exponent) {
  return x.toDouble().pow(exponent.toInt());
}

// Extension for pow
extension on double {
  double pow(int exponent) {
    if (exponent == 0) return 1.0;
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= this;
    }
    return result;
  }
}