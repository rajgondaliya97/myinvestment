import 'package:flutter/material.dart';

class NetworkData {
  // Available networks with their details
  static final List<Map<String, dynamic>> availableNetworks = [
    {
      'id': 'ethereum',
      'name': 'Ethereum',
      'symbol': 'ETH',
      'icon': Icons.currency_exchange,
      'color': Color(0xFF627EEA),
      'description': 'Ethereum Mainnet',
    },
    {
      'id': 'bsc',
      'name': 'BNB',
      'symbol': 'BNB',
      'icon': Icons.attach_money,
      'color': Color(0xFFF3BA2F),
      'description': 'Binance Smart Chain',
    },
    {
      'id': 'polygon',
      'name': 'Polygon',
      'symbol': 'MATIC',
      'icon': Icons.hexagon,
      'color': Color(0xFF8247E5),
      'description': 'Polygon Network',
    },
    {
      'id': 'sepolia',
      'name': 'Sepolia',
      'symbol': 'ETH',
      'icon': Icons.science,
      'color': Color(0xFF3099f2),
      'description': 'Ethereum Testnet',
    },
    {
      'id': 'goerli',
      'name': 'Goerli',
      'symbol': 'ETH',
      'icon': Icons.science_outlined,
      'color': Color(0xFF3099f2),
      'description': 'Ethereum Testnet',
    },
  ];

  static String getNativeSymbol(String? network) {
    final networkData = availableNetworks.firstWhere(
          (n) => n['id'] == network?.toLowerCase(),
      orElse: () => availableNetworks[0],
    );
    return networkData['symbol'] as String;
  }

  static Color getNetworkColor(String? network) {
    final networkData = availableNetworks.firstWhere(
          (n) => n['id'] == network?.toLowerCase(),
      orElse: () => availableNetworks[0],
    );
    return networkData['color'] as Color;
  }

  static IconData getNetworkIcon(String? network) {
    final networkData = availableNetworks.firstWhere(
          (n) => n['id'] == network?.toLowerCase(),
      orElse: () => availableNetworks[0],
    );
    return networkData['icon'] as IconData;
  }

  static String getNetworkDisplayName(String? network) {
    final networkData = availableNetworks.firstWhere(
          (n) => n['id'] == network?.toLowerCase(),
      orElse: () => availableNetworks[0],
    );
    return networkData['name'] as String;
  }
}