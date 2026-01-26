import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:reown_appkit/reown_appkit.dart';
import 'dart:typed_data';

class ReownWalletService extends ChangeNotifier {
  ReownAppKitModal? _appKitModal;
  String? _walletAddress;
  String? _chainId;
  bool _isConnected = false;
  Web3Client? _web3Client;
  Set<String> _connectedNetworks = {};

  // Getters
  String? get walletAddress => _walletAddress;
  String? get address => _walletAddress;
  String? get chainId => _chainId;
  String? get currentNetwork => _getNetworkNameFromChainId(_chainId);
  bool get isConnected => _isConnected;
  ReownAppKitModal? get appKitModal => _appKitModal;
  EthereumAddress? get ethereumAddress => _walletAddress != null
      ? EthereumAddress.fromHex(_walletAddress!)
      : null;

  // ✅ ADD THESE NEW GETTERS
  String? get activeNetwork => currentNetwork;
  Set<String> get connectedNetworks => _connectedNetworks;

  // RPC URLs
  static const Map<String, String> rpcUrls = {
    '1': 'https://eth-mainnet.g.alchemy.com/v2/tXuZERN9gTEEpQAtMccdf',
    '5': 'https://eth-goerli.g.alchemy.com/v2/tXuZERN9gTEEpQAtMccdf',
    '11155111': 'https://eth-sepolia.g.alchemy.com/v2/tXuZERN9gTEEpQAtMccdf',
    '137': 'https://polygon-mainnet.g.alchemy.com/v2/tXuZERN9gTEEpQAtMccdf',
    '80001': 'https://polygon-mumbai.g.alchemy.com/v2/tXuZERN9gTEEpQAtMccdf',
    '56': 'https://bsc-dataseed.binance.org/',
    '97': 'https://data-seed-prebsc-1-s1.binance.org:8545/',
  };

  // USDT Contract Addresses
  static const Map<String, String> _usdtContractAddresses = {
    '1': '0xdAC17F958D2ee523a2206206994597C13D831ec7',      // Ethereum
    '56': '0x55d398326f99059fF775485246999027B3197955',     // BSC
    '137': '0xc2132D05D31c914a87C6611C10748AEb04B58e8F',    // Polygon
    '11155111': '0x7169D38820dfd117C3FA1f22a697dBA58d90BA06', // Sepolia
    '5': '0x509Ee0d083DdF8AC028f2a56731412edD63223B9',      // Goerli
  };

  // USDT Decimals per network
  static const Map<String, int> _usdtDecimals = {
    '1': 6,      // Ethereum
    '56': 18,    // BSC
    '137': 6,    // Polygon
    '11155111': 6, // Sepolia
    '5': 6,      // Goerli
  };

  // ERC-20 ABI for token operations
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

  /// Initialize Reown AppKit
  /// Initialize Reown AppKit
  Future<void> initialize() async {
    debugPrint('🔧 Initializing Reown AppKit...');

    try {
      _appKitModal = ReownAppKitModal(
        context: NavigatorKey.navKey.currentContext!,
        projectId: '53fecf7a847cf88dc6e400066c217f36', // Keep your existing project ID
        metadata: const PairingMetadata(
          name: 'Infinite Wealth',  // ✅ Your app name from AndroidManifest
          description: 'Multi-chain cryptocurrency investment wallet',
          url: 'https://infinite-wealth.com',  // Update with your actual domain if you have one
          icons: ['https://infinite-wealth.com/icon.png'],  // Update with your actual icon URL
          redirect: Redirect(
            native: 'infinitewealth://',  // ✅ Matches your deep link scheme from AndroidManifest
            universal: 'https://infinite-wealth.com',  // Update with your actual domain
          ),
        ),
        requiredNamespaces: {
          'eip155': RequiredNamespace(
            chains: [
              'eip155:56',     // BSC
              'eip155:1',      // Ethereum
              'eip155:137',    // Polygon
              'eip155:11155111', // Sepolia
            ],
            methods: [
              'eth_sendTransaction',
              'eth_signTransaction',
              'eth_sign',
              'personal_sign',
              'eth_signTypedData',
            ],
            events: [
              'chainChanged',
              'accountsChanged',
            ],
          ),
        },
      );

      await _appKitModal!.init();
      _setupListeners();
      await _restoreSession();

      if (!_isConnected) {
        _chainId = '56'; // BSC as default
        _initWeb3Client(_chainId!);
      }

      debugPrint('✅ Reown AppKit initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize Reown AppKit: $e');
      rethrow;
    }
  }

  // ✅ ADD THESE HELPER METHODS FOR MULTI-NETWORK SUPPORT

  /// Get balances across all supported networks
  Future<Map<String, double>> getAllBalances() async {
    if (!_isConnected || _walletAddress == null) {
      return {};
    }

    Map<String, double> balances = {};

    // List of networks to check
    final networks = ['1', '56', '137', '11155111'];

    for (String networkChainId in networks) {
      try {
        // Temporarily switch to this network's RPC
        final rpcUrl = rpcUrls[networkChainId];
        if (rpcUrl == null) continue;

        final tempClient = Web3Client(rpcUrl, http.Client());

        String addressStr = _walletAddress!.toLowerCase();
        if (addressStr.startsWith('0x')) {
          addressStr = addressStr.substring(2);
        }

        final address = EthereumAddress.fromHex(addressStr);
        final balance = await tempClient.getBalance(address);

        final networkName = _getNetworkNameFromChainId(networkChainId) ?? networkChainId;
        balances[networkName] = balance.getValueInUnit(EtherUnit.ether);

        tempClient.dispose();
      } catch (e) {
        debugPrint('Failed to get balance for network $networkChainId: $e');
        final networkName = _getNetworkNameFromChainId(networkChainId) ?? networkChainId;
        balances[networkName] = 0.0;
      }
    }

    return balances;
  }

  /// Get USDT balances across all supported networks
  Future<Map<String, double>> getAllUsdtBalances() async {
    if (!_isConnected || _walletAddress == null) {
      return {};
    }

    Map<String, double> usdtBalances = {};

    // Only check networks that have USDT contracts
    final networksWithUsdt = ['1', '56', '137', '11155111'];

    for (String networkChainId in networksWithUsdt) {
      try {
        final contractAddress = _usdtContractAddresses[networkChainId];
        final networkName = _getNetworkNameFromChainId(networkChainId) ?? networkChainId;

        if (contractAddress == null) {
          usdtBalances[networkName] = 0.0;
          continue;
        }

        final rpcUrl = rpcUrls[networkChainId];
        if (rpcUrl == null) continue;

        final tempClient = Web3Client(rpcUrl, http.Client());
        final decimals = _usdtDecimals[networkChainId] ?? 6;

        final contract = DeployedContract(
          ContractAbi.fromJson(_erc20Abi, 'ERC20'),
          EthereumAddress.fromHex(contractAddress),
        );

        final balanceFunction = contract.function('balanceOf');
        final address = EthereumAddress.fromHex(_walletAddress!);

        final result = await tempClient.call(
          contract: contract,
          function: balanceFunction,
          params: [address],
        );

        final balance = result[0] as BigInt;
        final divisor = BigInt.from(10).pow(decimals);
        final balanceInUsdt = (balance / divisor).toDouble();

        usdtBalances[networkName] = balanceInUsdt;

        tempClient.dispose();
      } catch (e) {
        debugPrint('Failed to get USDT balance for network $networkChainId: $e');
        final networkName = _getNetworkNameFromChainId(networkChainId) ?? networkChainId;
        usdtBalances[networkName] = 0.0;
      }
    }

    return usdtBalances;
  }

  /// Setup AppKit listeners
  void _setupListeners() {
    _appKitModal!.addListener(() {
      final session = _appKitModal!.session;

      if (session != null) {
        final accounts = session.getAccounts() ?? [];
        if (accounts.isNotEmpty) {
          final addressParts = accounts.first.split(':');
          _walletAddress = addressParts.length >= 3 ? addressParts[2] : null;
          _chainId = addressParts.length >= 2 ? addressParts[1] : '56';
          _isConnected = true;

          // ✅ ADD: Track connected network
          final networkName = _getNetworkNameFromChainId(_chainId);
          if (networkName != null) {
            _connectedNetworks.add(networkName);
          }

          _initWeb3Client(_chainId!);
          _saveConnection();

          debugPrint('✅ Wallet connected: $_walletAddress on chain $_chainId');
        }
      } else {
        _walletAddress = null;
        _isConnected = false;
        debugPrint('🔌 Wallet disconnected');
      }

      notifyListeners();
    });

    _appKitModal!.onModalNetworkChange.subscribe((args) {
      if (args != null) {
        _chainId = args.chainId;

        // ✅ ADD: Track network when switching
        final networkName = _getNetworkNameFromChainId(_chainId);
        if (networkName != null) {
          _connectedNetworks.add(networkName);
        }

        _initWeb3Client(_chainId!);
        _saveConnection();
        debugPrint('🔄 Network changed to: $_chainId');
        notifyListeners();
      }
    });
  }
  // ✅ ADD THIS NEW METHOD
  /// Add a network to connected networks list
  Future<void> addNetwork(String networkId) async {
    try {
      debugPrint('📡 Adding network: $networkId');
      _connectedNetworks.add(networkId);
      notifyListeners();
      debugPrint('✅ Network added: $networkId');
    } catch (e) {
      debugPrint('❌ Failed to add network: $e');
      rethrow;
    }
  }

  /// Initialize Web3 client for a specific chain
  void _initWeb3Client(String chainId) {
    final rpcUrl = rpcUrls[chainId] ?? rpcUrls['56']!;
    _web3Client = Web3Client(rpcUrl, http.Client());
    debugPrint('🌐 Web3 client initialized for chain: $chainId');
  }

  /// Connect wallet - Opens AppKit Modal
  Future<void> connect() async {
    try {
      debugPrint('🔗 Opening AppKit Modal...');
      await _appKitModal!.openModalView();
    } catch (e) {
      debugPrint('❌ Connection failed: $e');
      rethrow;
    }
  }

  /// Disconnect wallet
  Future<void> disconnect({bool deleteStoredKey = false}) async {
    try {
      await _appKitModal!.disconnect();
      _walletAddress = null;
      _chainId = null;
      _isConnected = false;
      await _clearConnection();
      notifyListeners();
      debugPrint('🔌 Wallet disconnected');
    } catch (e) {
      debugPrint('❌ Disconnect failed: $e');
    }
  }

  /// Get wallet balance (Native token: ETH/BNB/MATIC)
  Future<EtherAmount> getBalance({String? network}) async {
    if (!_isConnected || _walletAddress == null || _web3Client == null) {
      throw Exception('Wallet not connected');
    }

    try {
      String addressStr = _walletAddress!.toLowerCase();
      if (addressStr.startsWith('0x')) {
        addressStr = addressStr.substring(2);
      }

      final address = EthereumAddress.fromHex(addressStr);
      debugPrint('💰 Fetching balance for: 0x$addressStr on chain $_chainId');

      final balance = await _web3Client!.getBalance(address);
      final symbol = getCurrencySymbol();

      debugPrint('💰 Balance: ${balance.getValueInUnit(EtherUnit.ether)} $symbol');
      return balance;
    } catch (e) {
      debugPrint('❌ Failed to get balance: $e');
      rethrow;
    }
  }

  /// Get balance in ether format (string)
  Future<String> getBalanceInEther({String? network}) async {
    final balance = await getBalance(network: network);
    return balance.getValueInUnit(EtherUnit.ether).toStringAsFixed(4);
  }

  /// Get USDT balance
  Future<String> getUsdtBalance({String? network}) async {
    if (!_isConnected || _walletAddress == null || _web3Client == null) {
      throw Exception('Wallet not connected');
    }

    final targetChainId = _chainId;
    final contractAddress = _usdtContractAddresses[targetChainId];

    if (contractAddress == null) {
      debugPrint('⚠️ USDT not supported on chain $targetChainId');
      throw Exception('USDT not supported on this network');
    }

    try {
      final decimals = _usdtDecimals[targetChainId] ?? 6;

      debugPrint('🪙 Getting USDT balance...');
      debugPrint('📍 Chain: $targetChainId');
      debugPrint('📍 Contract: $contractAddress');
      debugPrint('📍 Decimals: $decimals');

      final contract = DeployedContract(
        ContractAbi.fromJson(_erc20Abi, 'ERC20'),
        EthereumAddress.fromHex(contractAddress),
      );

      final balanceFunction = contract.function('balanceOf');
      final address = EthereumAddress.fromHex(_walletAddress!);

      final result = await _web3Client!.call(
        contract: contract,
        function: balanceFunction,
        params: [address],
      );

      final balance = result[0] as BigInt;
      debugPrint('📊 Raw USDT balance: $balance');

      final divisor = BigInt.from(10).pow(decimals);
      final balanceInUsdt = balance / divisor;

      debugPrint('💵 USDT Balance: $balanceInUsdt USDT');
      return balanceInUsdt.toStringAsFixed(2);
    } catch (e) {
      debugPrint('❌ USDT balance error: $e');
      rethrow;
    }
  }

  /// Get gas price
  Future<EtherAmount> getGasPrice({String? network}) async {
    if (_web3Client == null) {
      throw Exception('Web3 client not initialized');
    }

    try {
      final gasPrice = await _web3Client!.getGasPrice();
      debugPrint('⛽ Gas price: ${gasPrice.getValueInUnit(EtherUnit.gwei)} Gwei');
      return gasPrice;
    } catch (e) {
      debugPrint('❌ Gas price error: $e');
      rethrow;
    }
  }

  /// Send native token transaction (ETH/BNB/MATIC)
  Future<String> sendTransaction({
    required String toAddress,
    required String amountInEther,
    String? network,
  }) async {
    if (!_isConnected || _walletAddress == null) {
      throw Exception('Wallet not connected');
    }

    try {
      debugPrint('📤 Sending transaction...');
      debugPrint('To: $toAddress');
      debugPrint('Amount: $amountInEther ${getCurrencySymbol()}');

      final value = EtherAmount.fromUnitAndValue(
        EtherUnit.ether,
        double.parse(amountInEther),
      );

      final result = await _appKitModal!.request(
        topic: _appKitModal!.session!.topic,
        chainId: 'eip155:$_chainId',
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [
            {
              'from': _walletAddress,
              'to': toAddress,
              'value': '0x${value.getInWei.toRadixString(16)}',
            }
          ],
        ),
      );

      debugPrint('✅ Transaction sent: $result');
      return result.toString();
    } catch (e) {
      debugPrint('❌ Transaction failed: $e');
      rethrow;
    }
  }

  /// Send USDT token
  Future<String> sendUsdt({
    required String toAddress,
    required String amount,
    String? network,
  }) async {
    if (!_isConnected || _walletAddress == null) {
      throw Exception('Wallet not connected');
    }

    final contractAddress = _usdtContractAddresses[_chainId];
    if (contractAddress == null) {
      throw Exception('USDT not supported on this network');
    }

    try {
      final decimals = _usdtDecimals[_chainId] ?? 6;

      debugPrint('📤 Sending USDT...');
      debugPrint('To: $toAddress');
      debugPrint('Amount: $amount USDT');

      // Create contract instance
      final contract = DeployedContract(
        ContractAbi.fromJson(_erc20Abi, 'ERC20'),
        EthereumAddress.fromHex(contractAddress),
      );

      final transferFunction = contract.function('transfer');

      // Convert amount to smallest unit
      final amountInSmallestUnit = BigInt.from(
          double.parse(amount) * pow(10, decimals)
      );

      // Encode the contract call
      final data = transferFunction.encodeCall([
        EthereumAddress.fromHex(toAddress),
        amountInSmallestUnit,
      ]);

      // Send via WalletConnect
      final result = await _appKitModal!.request(
        topic: _appKitModal!.session!.topic,
        chainId: 'eip155:$_chainId',
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [
            {
              'from': _walletAddress,
              'to': contractAddress,
              'data': '0x${_bytesToHex(data)}',
            }
          ],
        ),
      );

      debugPrint('✅ USDT sent: $result');
      return result.toString();
    } catch (e) {
      debugPrint('❌ USDT send failed: $e');
      rethrow;
    }
  }

  /// Sign message
  Future<String> signMessage(String message) async {
    if (!_isConnected || _walletAddress == null) {
      throw Exception('Wallet not connected');
    }

    try {
      debugPrint('✍️ Signing message...');

      final result = await _appKitModal!.request(
        topic: _appKitModal!.session!.topic,
        chainId: 'eip155:$_chainId',
        request: SessionRequestParams(
          method: 'personal_sign',
          params: [message, _walletAddress],
        ),
      );

      debugPrint('✅ Message signed');
      return result.toString();
    } catch (e) {
      debugPrint('❌ Sign failed: $e');
      rethrow;
    }
  }


  /// Switch network
  Future<void> switchNetwork(String networkName) async {
    if (!_isConnected) {
      throw Exception('Wallet not connected');
    }

    final newChainId = _getChainIdFromNetwork(networkName);

    try {
      debugPrint('🔄 Switching to $networkName (chain $newChainId)...');

      await _appKitModal!.request(
        topic: _appKitModal!.session!.topic,
        chainId: 'eip155:$_chainId',
        request: SessionRequestParams(
          method: 'wallet_switchEthereumChain',
          params: [
            {'chainId': '0x${int.parse(newChainId).toRadixString(16)}'}
          ],
        ),
      );

      _chainId = newChainId;

      // ✅ ADD: Track the network as connected
      _connectedNetworks.add(networkName);

      _initWeb3Client(newChainId);
      await _saveConnection();
      notifyListeners();

      debugPrint('✅ Switched to $networkName');
    } catch (e) {
      debugPrint('❌ Network switch failed: $e');
      rethrow;
    }
  }

  /// Get currency symbol for current chain
  String getCurrencySymbol() {
    if (_chainId == '56' || _chainId == '97') {
      return 'BNB';
    } else if (_chainId == '137' || _chainId == '80001') {
      return 'MATIC';
    }
    return 'ETH';
  }

  /// Get network name
  String getNetworkName() {
    switch (_chainId) {
      case '1':
        return 'Ethereum Mainnet';
      case '56':
        return 'BNB Smart Chain';
      case '137':
        return 'Polygon';
      case '11155111':
        return 'Sepolia Testnet';
      case '97':
        return 'BSC Testnet';
      case '5':
        return 'Goerli Testnet';
      default:
        return 'Unknown Network';
    }
  }

  /// Get network name from chain ID
  String? _getNetworkNameFromChainId(String? chainId) {
    switch (chainId) {
      case '1':
        return 'ethereum';
      case '56':
        return 'bsc';
      case '137':
        return 'polygon';
      case '11155111':
        return 'sepolia';
      case '5':
        return 'goerli';
      default:
        return null;
    }
  }

  /// Get chain ID from network name
  String _getChainIdFromNetwork(String network) {
    switch (network.toLowerCase()) {
      case 'ethereum':
        return '1';
      case 'bsc':
        return '56';
      case 'polygon':
        return '137';
      case 'sepolia':
        return '11155111';
      case 'goerli':
        return '5';
      default:
        return '56'; // Default to BSC
    }
  }

  /// Get transaction explorer URL
  String getTransactionExplorerUrl(String txHash) {
    String baseUrl;
    switch (_chainId) {
      case '56':
        baseUrl = 'https://bscscan.com';
        break;
      case '137':
        baseUrl = 'https://polygonscan.com';
        break;
      case '11155111':
        baseUrl = 'https://sepolia.etherscan.io';
        break;
      case '1':
      default:
        baseUrl = 'https://etherscan.io';
    }
    return '$baseUrl/tx/$txHash';
  }

  /// Save connection state
  Future<void> _saveConnection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallet_address', _walletAddress ?? '');
    await prefs.setString('chain_id', _chainId ?? '56');
    await prefs.setBool('is_connected', _isConnected);

    // ✅ ADD: Save connected networks
    await prefs.setStringList('connected_networks', _connectedNetworks.toList());
  }

  /// Restore previous session
  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final wasConnected = prefs.getBool('is_connected') ?? false;

    if (wasConnected && _appKitModal!.session != null) {
      _walletAddress = prefs.getString('wallet_address');
      _chainId = prefs.getString('chain_id') ?? '56';
      _isConnected = true;

      // ✅ ADD: Restore connected networks
      final connectedNetworksJson = prefs.getStringList('connected_networks') ?? [];
      _connectedNetworks = Set<String>.from(connectedNetworksJson);

      // ✅ ADD: Add current network if not in set
      final currentNet = _getNetworkNameFromChainId(_chainId);
      if (currentNet != null) {
        _connectedNetworks.add(currentNet);
      }

      _initWeb3Client(_chainId!);
      debugPrint('✅ Session restored: $_walletAddress on chain $_chainId');
      notifyListeners();
    }
  }

  /// Clear saved connection
  Future<void> _clearConnection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wallet_address');
    await prefs.remove('chain_id');
    await prefs.remove('is_connected');

    // ✅ ADD: Clear connected networks
    await prefs.remove('connected_networks');
    _connectedNetworks.clear();
  }

  /// Helper: Convert bytes to hex string
  String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }

  @override
  void dispose() {
    _web3Client?.dispose();
    _appKitModal?.dispose();
    super.dispose();
  }
}

/// Global Navigator Key for context access
class NavigatorKey {
  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
}

/// Helper function for pow
num pow(num x, num exponent) {
  return x.toDouble().pow(exponent.toInt());
}

/// Extension for pow
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