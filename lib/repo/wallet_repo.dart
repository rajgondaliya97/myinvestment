import 'package:myinvestment/api_services/api_service.dart';
import '../model/wallet_model/add_wallet_balance_model.dart';
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
}