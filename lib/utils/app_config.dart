import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static Future init() async {  // ADD  ✅
    await dotenv.load(fileName: ".env");
  }

  // WalletConnect Project ID
  static String get walletConnectProjectId =>
      dotenv.env['WALLETCONNECT_PROJECT_ID'] ?? '';

  // Infura Project ID
  static String get infuraProjectId =>
      dotenv.env['INFURA_PROJECT_ID'] ?? '';

  // Network Configuration
  static String get defaultNetwork =>
      dotenv.env['DEFAULT_NETWORK'] ?? 'mainnet';

  // RPC URLs
  static String getRpcUrl(String network) {
    final projectId = infuraProjectId;
    switch (network) {
      case 'mainnet':
        return 'https://mainnet.infura.io/v3/$projectId';
      case 'sepolia':
        return 'https://sepolia.infura.io/v3/$projectId';
      case 'polygon':
        return 'https://polygon-mainnet.infura.io/v3/$projectId';
      default:
        return 'https://mainnet.infura.io/v3/$projectId';
    }
  }

  // Chain IDs
  static int getChainId(String network) {
    switch (network) {
      case 'mainnet':
        return 1;
      case 'sepolia':
        return 11155111;
      case 'polygon':
        return 137;
      case 'bsc':
        return 56;
       default:
        return 1;
    }
  }

  // Supported Chains for WalletConnect - REMOVE ? ✅
  static List<String> get supportedChains => [
    'eip155:1',        // Ethereum Mainnet
    'eip155:137',      // Polygon
    'eip155:56',       // BSC
    'eip155:11155111', // Sepolia Testnet
  ];
}