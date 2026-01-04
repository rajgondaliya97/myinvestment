import 'package:flutter/cupertino.dart';
import '../api_services/api_exception.dart';
import '../model/wallet_model/add_wallet_balance_model.dart';
import '../repo/wallet_repo.dart';

class WalletController extends ChangeNotifier {
  final WalletRepository walletRepository;
  WalletController({required this.walletRepository});

  bool _isLoading = false;
  String? _errorMessage;
  AddWalletBalanceModelData? _walletData;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AddWalletBalanceModelData? get walletData => _walletData;

  /// Add balance to wallet
  Future<bool> addWalletBalance({required int balance}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('💰 Adding wallet balance: \$${balance}');

      final response = await walletRepository.addWalletBalance(balance: balance);

      print('📊 Add Wallet Response Status: ${response.status}');
      print('📊 Message: ${response.message}');
      print('📊 New Balance: ${response.data?.balance}');

      if (response.status == 0 && response.data != null) {
        _walletData = response.data;
        print('✅ Wallet balance added successfully');
        print('✅ User ID: ${_walletData?.userId}');
        print('✅ Current Balance: \$${_walletData?.balance}');

        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to add wallet balance';
        print('❌ Add wallet balance failed: $_errorMessage');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      print('❌ ApiException: ${e.message}');
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Exception: $e');
      _errorMessage = 'Failed to add wallet balance';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearWalletData() {
    _walletData = null;
    notifyListeners();
  }
}