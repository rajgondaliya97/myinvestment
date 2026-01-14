import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../utils/app_config.dart';

/// Network Connection Model
class NetworkConnection {
  final String networkName;
  final Web3Client client;
  final String rpcUrl;

  NetworkConnection({
    required this.networkName,
    required this.client,
    required this.rpcUrl,
  });

  void dispose() {
    client.dispose();
  }
}

class Web3WalletService extends ChangeNotifier {
  // Multiple network connections
  final Map<String, NetworkConnection> _networkConnections = {};

  EthPrivateKey? _credentials;
  EthereumAddress? _address;
  bool _isConnected = false;
  String? _activeNetwork; // Currently active/selected network

  // Secure storage for private key
  final _secureStorage = const FlutterSecureStorage();
  static const String _privateKeyKey = 'wallet_private_key';
  static const String _activeNetworkKey = 'active_network';
  static const String _enabledNetworksKey = 'enabled_networks';

  // USDT Contract Addresses
  static const Map<String, String> _usdtContractAddresses = {
    'ethereum': '0xdAC17F958D2ee523a2206206994597C13D831ec7',
    'bsc': '0x55d398326f99059fF775485246999027B3197955',
    'polygon': '0xc2132D05D31c914a87C6611C10748AEb04B58e8F',
    'sepolia': '0x7169D38820dfd117C3FA1f22a697dBA58d90BA06',
    'goerli': '0x509Ee0d083DdF8AC028f2a56731412edD63223B9',
  };

  // Token decimals per network
  static const Map<String, int> _usdtDecimals = {
    'ethereum': 6,
    'bsc': 18,
    'polygon': 6,
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

  // Getters
  String? get address => _address?.toString();
  bool get isConnected => _isConnected;
  String? get currentNetwork => _activeNetwork;
  String? get activeNetwork => _activeNetwork;
  List<String> get connectedNetworks => _networkConnections.keys.toList();
  EthereumAddress? get ethereumAddress => _address;

  /// Initialize the service with multiple networks
  Future<void> initialize({List<String>? enabledNetworks}) async {
    debugPrint('🔧 [Web3Wallet] Initializing Multi-Network Service...');

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load active network
      _activeNetwork = prefs.getString(_activeNetworkKey) ?? AppConfig.defaultNetwork;

      // Load enabled networks or use defaults
      final savedNetworks = prefs.getStringList(_enabledNetworksKey);
      final networksToConnect = enabledNetworks ??
          savedNetworks ??
          [AppConfig.defaultNetwork]; // Start with just default network

      debugPrint('🌐 [Web3Wallet] Networks to connect: $networksToConnect');
      debugPrint('📍 Active Network: $_activeNetwork');

      // Connect to all enabled networks
      for (final network in networksToConnect) {
        try {
          await _connectToNetwork(network);
        } catch (e) {
          debugPrint('⚠️ [Web3Wallet] Failed to connect to $network: $e');
        }
      }

      // Check for saved private key
      final savedKey = await _secureStorage.read(key: _privateKeyKey);
      if (savedKey != null && savedKey.isNotEmpty) {
        await _loadWalletFromPrivateKey(savedKey);
        debugPrint('✅ [Web3Wallet] Auto-loaded saved wallet');
        debugPrint('📍 Address: ${_address?.toString()}');
      }

      debugPrint('✅ [Web3Wallet] Service initialized');
      debugPrint('🌐 Connected to ${_networkConnections.length} networks');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Initialization error: $e');
      rethrow;
    }
  }

  /// Connect to a specific network
  Future<void> _connectToNetwork(String network) async {
    if (_networkConnections.containsKey(network)) {
      debugPrint('⚠️ [Web3Wallet] Already connected to $network');
      return;
    }

    try {
      final rpcUrl = AppConfig.getRpcUrl(network);
      final client = Web3Client(rpcUrl, http.Client());

      _networkConnections[network] = NetworkConnection(
        networkName: network,
        client: client,
        rpcUrl: rpcUrl,
      );

      debugPrint('🌐 [Web3Wallet] Connected to $network');
      debugPrint('🌐 [Web3Wallet] RPC URL: $rpcUrl');
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Failed to connect to $network: $e');
      rethrow;
    }
  }

  /// Add a new network connection
  Future<void> addNetwork(String network) async {
    debugPrint('➕ [Web3Wallet] Adding network: $network');

    await _connectToNetwork(network);

    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    final enabledNetworks = _networkConnections.keys.toList();
    await prefs.setStringList(_enabledNetworksKey, enabledNetworks);

    debugPrint('✅ [Web3Wallet] Network added: $network');
    notifyListeners();
  }

  /// Remove a network connection
  Future<void> removeNetwork(String network) async {
    if (network == _activeNetwork) {
      throw Exception('Cannot remove active network. Switch to another network first.');
    }

    final connection = _networkConnections.remove(network);
    connection?.dispose();

    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    final enabledNetworks = _networkConnections.keys.toList();
    await prefs.setStringList(_enabledNetworksKey, enabledNetworks);

    debugPrint('🗑️ [Web3Wallet] Removed network: $network');
    notifyListeners();
  }

  /// Switch active network
  Future<void> switchNetwork(String network) async {
    if (!_networkConnections.containsKey(network)) {
      // If network is not connected, add it first
      await addNetwork(network);
    }

    _activeNetwork = network;

    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeNetworkKey, network);

    debugPrint('🔄 [Web3Wallet] Switched active network to $network');
    notifyListeners();
  }

  /// Import wallet using private key
  Future<void> importWalletFromPrivateKey(String privateKey, {bool saveKey = true}) async {
    try {
      debugPrint('🔑 [Web3Wallet] Importing wallet from private key...');

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

  /// Get wallet balance for a specific network (ETH/BNB/Native token)
  Future<EtherAmount> getBalance({String? network}) async {
    if (!_isConnected || _address == null) {
      throw Exception('Wallet not connected');
    }

    final targetNetwork = network ?? _activeNetwork;
    final connection = _networkConnections[targetNetwork];

    if (connection == null) {
      throw Exception('Not connected to $targetNetwork');
    }

    try {
      final balance = await connection.client.getBalance(_address!);
      final nativeSymbol = _getNativeSymbol(targetNetwork!);
      debugPrint('💰 [Web3Wallet] Balance on $targetNetwork: ${balance.getValueInUnit(EtherUnit.ether)} $nativeSymbol');
      return balance;
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Balance error on $targetNetwork: $e');
      rethrow;
    }
  }

  /// Get balances across all connected networks
  Future<Map<String, double>> getAllBalances() async {
    if (!_isConnected || _address == null) {
      throw Exception('Wallet not connected');
    }

    final balances = <String, double>{};

    debugPrint('💰 [Web3Wallet] Fetching balances for all networks...');

    for (final network in _networkConnections.keys) {
      try {
        final balance = await getBalance(network: network);
        balances[network] = double.parse(
            balance.getValueInUnit(EtherUnit.ether).toStringAsFixed(6)
        );
      } catch (e) {
        debugPrint('⚠️ [Web3Wallet] Failed to get balance for $network: $e');
        balances[network] = 0.0;
      }
    }

    debugPrint('✅ [Web3Wallet] All balances: $balances');
    return balances;
  }

  String _getNativeSymbol(String network) {
    switch (network) {
      case 'ethereum':
      case 'sepolia':
      case 'goerli':
        return 'ETH';
      case 'bsc':
        return 'BNB';
      case 'polygon':
        return 'MATIC';
      default:
        return 'ETH';
    }
  }

  /// Get balance in specific unit for active network
  Future<String> getBalanceInEther({String? network}) async {
    final balance = await getBalance(network: network);
    return balance.getValueInUnit(EtherUnit.ether).toStringAsFixed(4);
  }

  /// Get USDT balance for specific network
  Future<String> getUsdtBalance({String? network}) async {
    if (!_isConnected || _address == null) {
      throw Exception('Wallet not connected');
    }

    final targetNetwork = network ?? _activeNetwork;
    final connection = _networkConnections[targetNetwork];

    if (connection == null) {
      throw Exception('Not connected to $targetNetwork');
    }

    final contractAddress = _usdtContractAddresses[targetNetwork];
    if (contractAddress == null) {
      debugPrint('⚠️ [Web3Wallet] USDT not supported on $targetNetwork');
      throw Exception('USDT not supported on $targetNetwork');
    }

    try {
      final decimals = _usdtDecimals[targetNetwork] ?? 6;

      debugPrint('🪙 [Web3Wallet] Getting USDT balance...');
      debugPrint('📍 Network: $targetNetwork');
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
      final result = await connection.client.call(
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

      debugPrint('💵 [Web3Wallet] USDT Balance on $targetNetwork: $balanceInUsdt USDT');

      return balanceInUsdt.toStringAsFixed(2);
    } catch (e) {
      debugPrint('❌ [Web3Wallet] USDT balance error on $targetNetwork: $e');
      rethrow;
    }
  }

  /// Get USDT balances across all connected networks
  Future<Map<String, double>> getAllUsdtBalances() async {
    if (!_isConnected || _address == null) {
      throw Exception('Wallet not connected');
    }

    final balances = <String, double>{};

    debugPrint('💵 [Web3Wallet] Fetching USDT balances for all networks...');

    for (final network in _networkConnections.keys) {
      if (_usdtContractAddresses.containsKey(network)) {
        try {
          final balance = await getUsdtBalance(network: network);
          balances[network] = double.parse(balance);
        } catch (e) {
          debugPrint('⚠️ [Web3Wallet] Failed to get USDT for $network: $e');
          balances[network] = 0.0;
        }
      }
    }

    debugPrint('✅ [Web3Wallet] All USDT balances: $balances');
    return balances;
  }

  /// Get ERC-20 token balance (generic)
  Future<String> getTokenBalance({
    required String contractAddress,
    int decimals = 18,
    String? network,
  }) async {
    if (!_isConnected || _address == null) {
      throw Exception('Wallet not connected');
    }

    final targetNetwork = network ?? _activeNetwork;
    final connection = _networkConnections[targetNetwork];

    if (connection == null) {
      throw Exception('Not connected to $targetNetwork');
    }

    try {
      debugPrint('🪙 [Web3Wallet] Getting token balance for $contractAddress on $targetNetwork...');

      // Create contract instance
      final contract = DeployedContract(
        ContractAbi.fromJson(_erc20Abi, 'ERC20'),
        EthereumAddress.fromHex(contractAddress),
      );

      // Get balanceOf function
      final balanceFunction = contract.function('balanceOf');

      // Call the contract
      final result = await connection.client.call(
        contract: contract,
        function: balanceFunction,
        params: [_address!],
      );

      // Parse balance
      final balance = result[0] as BigInt;
      final balanceInToken = balance / BigInt.from(10).pow(decimals);

      debugPrint('💰 [Web3Wallet] Token Balance on $targetNetwork: $balanceInToken');

      return balanceInToken.toStringAsFixed(decimals > 6 ? 6 : decimals);
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Token balance error on $targetNetwork: $e');
      rethrow;
    }
  }

  /// Send USDT on specific network
  Future<String> sendUsdt({
    required String toAddress,
    required String amount,
    String? network,
  }) async {
    if (!_isConnected || _credentials == null) {
      throw Exception('Wallet not connected');
    }

    final targetNetwork = network ?? _activeNetwork;
    final connection = _networkConnections[targetNetwork];

    if (connection == null) {
      throw Exception('Not connected to $targetNetwork');
    }

    final contractAddress = _usdtContractAddresses[targetNetwork];
    if (contractAddress == null) {
      throw Exception('USDT not supported on $targetNetwork');
    }

    try {
      final decimals = _usdtDecimals[targetNetwork] ?? 6;

      debugPrint('📤 [Web3Wallet] Sending USDT on $targetNetwork...');
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

      final chainId = await _getChainId(targetNetwork!);

      final txHash = await connection.client.sendTransaction(
        _credentials!,
        transaction,
        chainId: chainId,
      );

      debugPrint('✅ [Web3Wallet] USDT sent on $targetNetwork!');
      debugPrint('✅ Hash: $txHash');

      return txHash;
    } catch (e) {
      debugPrint('❌ [Web3Wallet] USDT send error on $targetNetwork: $e');
      rethrow;
    }
  }

  /// Send native token (ETH/BNB/MATIC) transaction on specific network
  Future<String> sendTransaction({
    required String toAddress,
    required String amountInEther,
    String? network,
    String? data,
    int? customGasLimit,
    EtherAmount? customGasPrice,
  }) async {
    if (!_isConnected || _credentials == null) {
      throw Exception('Wallet not connected');
    }

    final targetNetwork = network ?? _activeNetwork;
    final connection = _networkConnections[targetNetwork];

    if (connection == null) {
      throw Exception('Not connected to $targetNetwork');
    }

    try {
      debugPrint('📤 [Web3Wallet] Sending transaction on $targetNetwork...');
      debugPrint('To: $toAddress');
      debugPrint('Amount: $amountInEther ${_getNativeSymbol(targetNetwork!)}');

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

      final chainId = await _getChainId(targetNetwork);

      final txHash = await connection.client.sendTransaction(
        _credentials!,
        transaction,
        chainId: chainId,
      );

      debugPrint('✅ [Web3Wallet] Transaction sent on $targetNetwork!');
      debugPrint('✅ Hash: $txHash');

      return txHash;
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Transaction error on $targetNetwork: $e');
      rethrow;
    }
  }

  /// Sign a message
  Future<String> signMessage(String message) async {
    if (!_isConnected || _credentials == null) {
      throw Exception('Wallet not connected');
    }

    try {
      debugPrint('✏️ [Web3Wallet] Signing message...');

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

  /// Get current gas price for specific network
  Future<EtherAmount> getGasPrice({String? network}) async {
    final targetNetwork = network ?? _activeNetwork;
    final connection = _networkConnections[targetNetwork];

    if (connection == null) {
      throw Exception('Not connected to $targetNetwork');
    }

    try {
      final gasPrice = await connection.client.getGasPrice();
      debugPrint('⛽ [Web3Wallet] Gas price on $targetNetwork: ${gasPrice.getValueInUnit(EtherUnit.gwei)} Gwei');
      return gasPrice;
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Gas price error on $targetNetwork: $e');
      rethrow;
    }
  }

  /// Get chain ID for specific network
  Future<int> _getChainId(String network) async {
    final connection = _networkConnections[network];
    if (connection == null) {
      throw Exception('Not connected to $network');
    }

    try {
      final chainId = await connection.client.getChainId();
      return chainId.toInt();
    } catch (e) {
      debugPrint('⚠️ [Web3Wallet] Chain ID error, using configured value');
      return AppConfig.getChainId(network);
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

  /// Disconnect all networks and clear wallet
  Future<void> disconnectAllNetworks() async {
    try {
      debugPrint('🔌 [Web3Wallet] Disconnecting all networks...');

      for (final connection in _networkConnections.values) {
        connection.dispose();
      }
      _networkConnections.clear();

      await disconnect(deleteStoredKey: true);

      // Clear preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_enabledNetworksKey);

      debugPrint('✅ [Web3Wallet] All networks disconnected');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [Web3Wallet] Disconnect all error: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    for (final connection in _networkConnections.values) {
      connection.dispose();
    }
    _networkConnections.clear();
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

// Helper for hex conversion
Uint8List hexToBytes(String hexStr) {
  final hex = hexStr.replaceAll('0x', '');
  final List<int> bytes = [];
  for (var i = 0; i < hex.length; i += 2) {
    bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
  }
  return Uint8List.fromList(bytes);
}