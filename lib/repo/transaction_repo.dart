import 'package:myinvestment/utils/app_urls.dart';

import '../api_services/api_service.dart';
import '../model/transaction_model/transaction_history_model.dart';

class TransactionRepository {
  final ApiService apiService;
  TransactionRepository({required this.apiService});

  Future<TransactionHistoryModel> getTransactionHistory({
    required int limit,
    required int page,
    String? search,
    String? sort,
  }) async {
    print('🔍 TransactionRepository.getTransactionHistory called');
    print('🔍 Params - limit: $limit, page: $page, search: $search, sort: $sort');

    // Your API call here
    final response = await apiService.post(
      AppUrl.getTransactionsUrl,
      body: {
      'limit': limit,
      'page': page,
      'search': search,
      'sort': sort,
    },
    );

    print('🔍 API Response: $response');

    return TransactionHistoryModel.fromJson(response);
  }
}