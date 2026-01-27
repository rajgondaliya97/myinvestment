import 'package:flutter/cupertino.dart';
import '../api_services/api_exception.dart';
import '../model/wallet_model/add_wallet_balance_model.dart';
import '../model/wallet_model/get_wallet_balance_model.dart';
import '../model/wallet_model/withdraw_balance_model.dart';
import '../repo/wallet_repo.dart';

class WalletController extends ChangeNotifier {
  final WalletRepository walletRepository;
  WalletController({required this.walletRepository});

  bool _isLoading = false;
  bool _isFetchingBalance = false;
  String? _errorMessage;
  AddWalletBalanceModelData? _walletData;
  GetWalletBalanceModelData? _balanceData;
  WithdrawBalanceModelData? _withdrawData;

  // Getters
  bool get isLoading => _isLoading;
  bool get isFetchingBalance => _isFetchingBalance;
  String? get errorMessage => _errorMessage;
  AddWalletBalanceModelData? get walletData => _walletData;
  GetWalletBalanceModelData? get balanceData => _balanceData;
  WithdrawBalanceModelData? get withdrawData => _withdrawData;

  // Get current balance
  dynamic get currentBalance => _balanceData?.balance ?? 0;
  dynamic get lockedBalance => _balanceData?.lockedBalance ?? 0;
  dynamic get availableBalance => currentBalance - lockedBalance;

  /// Fetch wallet balance
  Future<void> fetchWalletBalance() async {
    _isFetchingBalance = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📡 Fetching wallet balance...');

      final response = await walletRepository.getWalletBalance();

      print('📊 Get Balance Response Status: ${response.status}');
      print('📊 Message: ${response.message}');
      print('📊 Balance: ${response.data?.balance}');
      print('📊 Locked Balance: ${response.data?.lockedBalance}');

      if (response.status == 0 && response.data != null) {
        _balanceData = response.data;
        print('✅ Wallet balance fetched successfully');
        print('✅ Current Balance: \$${_balanceData?.balance}');
        print('✅ Locked Balance: \$${_balanceData?.lockedBalance}');

        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Failed to fetch wallet balance';
        print('❌ Fetch wallet balance failed: $_errorMessage');
      }
    } on ApiException catch (e) {
      print('❌ ApiException: ${e.message}');
      _errorMessage = e.message;
    } catch (e) {
      print('❌ Exception: $e');
      _errorMessage = 'Failed to fetch wallet balance';
    }

    _isFetchingBalance = false;
    notifyListeners();
  }

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

        // Refresh wallet balance after adding
        await fetchWalletBalance();

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

  /// Withdraw balance from wallet
  Future<bool> withdrawBalance({
    required int amount,
    required String address,
    required String transactionMethod,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('💸 Withdrawing balance: \$${amount}');
      print('📍 Address: $address');
      print('💳 Transaction Method: $transactionMethod');

      final response = await walletRepository.withdrawBalance(
        amount: amount,
        address: address,
        transactionMethod: transactionMethod,
      );

      print('📊 Withdraw Response Status: ${response.status}');
      print('📊 Message: ${response.message}');
      print('📊 Withdrawn Amount: ${response.data?.amount}');
      print('📊 Remaining Balance: ${response.data?.remainingBalance}');
      print('📊 Transaction ID: ${response.data?.transactionId}');

      if (response.status == 0 && response.data != null) {
        _withdrawData = response.data;
        print('✅ Withdrawal successful');
        print('✅ User ID: ${_withdrawData?.userId}');
        print('✅ Amount: \$${_withdrawData?.amount}');
        print('✅ Remaining Balance: \$${_withdrawData?.remainingBalance}');

        // Refresh wallet balance after withdrawal
        await fetchWalletBalance();

        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to withdraw balance';
        print('❌ Withdrawal failed: $_errorMessage');
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
      _errorMessage = 'Failed to withdraw balance';
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
    _balanceData = null;
    _withdrawData = null;
    notifyListeners();
  }
}