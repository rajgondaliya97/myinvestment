import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  /// Initialize app config - loads .env file
  static Future<void> init() async {
    debugPrint('🔧 [AppConfig] Initializing...');

    try {
      await dotenv.load(fileName: ".env");
      debugPrint('✅ [AppConfig] .env file loaded');
    } catch (e) {
      debugPrint('⚠️ [AppConfig] .env file not found, using defaults: $e');
    }

    debugPrint('📍 [AppConfig] Default Network: $defaultNetwork');
    debugPrint('🌐 [AppConfig] RPC URL: ${getRpcUrl(defaultNetwork)}');
    debugPrint('✅ [AppConfig] Initialized successfully');
  }

  // WalletConnect Project ID
  static String get walletConnectProjectId =>
      dotenv.env['WALLETCONNECT_PROJECT_ID'] ?? '';

  // Infura Project ID
  static String get infuraProjectId =>
      dotenv.env['INFURA_PROJECT_ID'] ?? '';

  // Default network - CHANGED TO BSC as default
  static String get defaultNetwork {
    final envNetwork = dotenv.env['DEFAULT_NETWORK'] ?? 'bsc';
    // Map 'mainnet' to 'ethereum' for consistency
    if (envNetwork == 'mainnet') {
      return 'ethereum';
    }
    return envNetwork;
  }

  // RPC URLs - UPDATED with BSC support
  static String getRpcUrl(String network) {
    final projectId = infuraProjectId;

    switch (network.toLowerCase()) {
      case 'mainnet':
      case 'ethereum':
        return projectId.isNotEmpty
            ? 'https://mainnet.infura.io/v3/$projectId'
            : 'https://eth-mainnet.g.alchemy.com/v2/demo';

      case 'sepolia':
        return projectId.isNotEmpty
            ? 'https://sepolia.infura.io/v3/$projectId'
            : 'https://rpc.sepolia.org/';

      case 'polygon':
        return projectId.isNotEmpty
            ? 'https://polygon-mainnet.infura.io/v3/$projectId'
            : 'https://polygon-rpc.com/';

      case 'bsc':
      // Use multiple BSC RPC endpoints for reliability
        return 'https://bsc-dataseed1.binance.org/';

      case 'goerli':
        return projectId.isNotEmpty
            ? 'https://goerli.infura.io/v3/$projectId'
            : 'https://goerli.infura.io/v3/demo';

      default:
        debugPrint('⚠️ Unknown network: $network, using BSC');
        return 'https://bsc-dataseed1.binance.org/';
    }
  }

  // Alternative BSC RPC URLs (for failover)
  static List<String> getBscRpcUrls() {
    return [
      'https://bsc-dataseed1.binance.org/',
      'https://bsc-dataseed2.binance.org/',
      'https://bsc-dataseed3.binance.org/',
      'https://bsc-dataseed4.binance.org/',
    ];
  }

  // Chain IDs
  static int getChainId(String network) {
    switch (network.toLowerCase()) {
      case 'mainnet':
      case 'ethereum':
        return 1;
      case 'sepolia':
        return 11155111;
      case 'polygon':
        return 137;
      case 'bsc':
        return 56;
      case 'goerli':
        return 5;
      default:
        return 56; // Default to BSC
    }
  }

  // Block explorer URLs
  static String getExplorerUrl(String network) {
    switch (network.toLowerCase()) {
      case 'mainnet':
      case 'ethereum':
        return 'https://etherscan.io';
      case 'bsc':
        return 'https://bscscan.com';
      case 'polygon':
        return 'https://polygonscan.com';
      case 'sepolia':
        return 'https://sepolia.etherscan.io';
      case 'goerli':
        return 'https://goerli.etherscan.io';
      default:
        return 'https://bscscan.com';
    }
  }

  // Get transaction URL
  static String getTransactionUrl(String network, String txHash) {
    return '${getExplorerUrl(network)}/tx/$txHash';
  }

  // Get address URL
  static String getAddressUrl(String network, String address) {
    return '${getExplorerUrl(network)}/address/$address';
  }

  // Supported Chains for WalletConnect
  static List<String> get supportedChains => [
    'eip155:1',        // Ethereum Mainnet
    'eip155:137',      // Polygon
    'eip155:56',       // BSC
    'eip155:11155111', // Sepolia Testnet
  ];

  // Get all supported networks
  static List<String> getSupportedNetworks() {
    return ['ethereum', 'bsc', 'polygon', 'sepolia', 'goerli'];
  }

  // Check if network is supported
  static bool isNetworkSupported(String network) {
    return getSupportedNetworks().contains(network.toLowerCase());
  }

  // Get network display name
  static String getNetworkDisplayName(String network) {
    switch (network.toLowerCase()) {
      case 'ethereum':
      case 'mainnet':
        return 'Ethereum Mainnet';
      case 'bsc':
        return 'Binance Smart Chain (BNB)';
      case 'polygon':
        return 'Polygon';
      case 'sepolia':
        return 'Sepolia Testnet';
      case 'goerli':
        return 'Goerli Testnet';
      default:
        return network;
    }
  }

  // Normalize network name (mainnet -> ethereum, etc.)
  static String normalizeNetworkName(String network) {
    switch (network.toLowerCase()) {
      case 'mainnet':
        return 'ethereum';
      case 'bnb':
      case 'binance':
        return 'bsc';
      default:
        return network.toLowerCase();
    }
  }
}