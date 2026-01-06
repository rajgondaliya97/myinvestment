import 'package:myinvestment/api_services/api_service.dart';
import '../model/wallet_model/add_wallet_balance_model.dart';
import '../model/wallet_model/get_wallet_balance_model.dart';
import '../model/wallet_model/withdraw_balance_model.dart';
import '../utils/app_urls.dart';

class WalletRepository {
  final ApiService apiService;
  WalletRepository({required this.apiService});

  /// Add balance to wallet
  Future<AddWalletBalanceModel> addWalletBalance({
    required int balance,
  }) async {
    try {
      final response = await apiService.post(
        AppUrl.addWalletBalanceUrl,
        body: {'amount': balance},
      );
      return AddWalletBalanceModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get wallet balance
  Future<GetWalletBalanceModel> getWalletBalance() async {
    try {
      final response = await apiService.get(
        AppUrl.getWalletBalanceUrl,
      );
      return GetWalletBalanceModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Withdraw balance from wallet
  Future<WithdrawBalanceModel> withdrawBalance({
    required int amount,
    required String transactionMethod,
  }) async {
    try {
      final response = await apiService.post(
        AppUrl.withdrawRequestUrl,
        body: {
          "amount": amount,
          "transaction_method":transactionMethod},
      );
      return WithdrawBalanceModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}