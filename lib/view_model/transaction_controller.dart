import 'package:flutter/cupertino.dart';
import '../api_services/api_exception.dart';
import '../model/transaction_model/transaction_history_model.dart';
import '../repo/transaction_repo.dart';

class TransactionController extends ChangeNotifier {
  final TransactionRepository transactionRepository;
  TransactionController({required this.transactionRepository});

  // Transaction History State
  List<TransactionHistoryModelData> _transactions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _sortOrder = 'desc';

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  int _perPage = 10;
  int _total = 0;
  bool _hasMoreData = true;

  // Getters
  List<TransactionHistoryModelData> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get sortOrder => _sortOrder;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  bool get hasMoreData => _hasMoreData;

  // Filter transactions by type
  List<TransactionHistoryModelData> get creditTransactions {
    return _transactions.where((t) => t.type?.toLowerCase() == 'credit').toList();
  }

  List<TransactionHistoryModelData> get debitTransactions {
    return _transactions.where((t) => t.type?.toLowerCase() == 'debit').toList();
  }

  // Filter by category
  List<TransactionHistoryModelData> getTransactionsByCategory(String category) {
    return _transactions.where((t) => t.category?.toLowerCase() == category.toLowerCase()).toList();
  }

  /// Fetch transaction history (first page or refresh)
  Future<void> fetchTransactionHistory({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _transactions.clear();
      _hasMoreData = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📡 Fetching transaction history - Page: $_currentPage');

      final response = await transactionRepository.getTransactionHistory(
        limit: _perPage,
        page: _currentPage,
        search: _searchQuery,
        sort: _sortOrder,
      );

      print('📊 Transaction History Response Status: ${response.status}');
      print('📊 Total Transactions: ${response.pagination?.total}');

      if (response.status == 1 && response.data != null) {
        if (refresh) {
          _transactions = response.data!;
        } else {
          _transactions.addAll(response.data!);
        }

        // Update pagination info
        if (response.pagination != null) {
          _currentPage = response.pagination!.currentPage ?? 1;
          _lastPage = response.pagination!.lastPage ?? 1;
          _perPage = response.pagination!.perPage ?? 10;
          _total = response.pagination!.total ?? 0;
          _hasMoreData = _currentPage < _lastPage;
        }

        print('✅ Loaded ${_transactions.length} transactions');
        print('✅ Has More Data: $_hasMoreData');

        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Failed to fetch transactions';
        print('❌ Transactions fetch failed');
      }
    } on ApiException catch (e) {
      print('❌ ApiException: ${e.message}');
      _errorMessage = e.message;
    } catch (e) {
      print('❌ Exception: $e');
      _errorMessage = 'Failed to load transactions';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load more transactions (pagination)
  Future<void> loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      print('📡 Loading more transactions - Page: $_currentPage');

      final response = await transactionRepository.getTransactionHistory(
        limit: _perPage,
        page: _currentPage,
        search: _searchQuery,
        sort: _sortOrder,
      );

      if (response.status == 0 && response.data != null) {
        _transactions.addAll(response.data!);

        if (response.pagination != null) {
          _currentPage = response.pagination!.currentPage ?? _currentPage;
          _lastPage = response.pagination!.lastPage ?? _lastPage;
          _hasMoreData = _currentPage < _lastPage;
        }

        print('✅ Loaded more transactions. Total: ${_transactions.length}');
      }
    } on ApiException catch (e) {
      print('❌ Load more failed: ${e.message}');
      _currentPage--; // Revert page increment
    } catch (e) {
      print('❌ Load more exception: $e');
      _currentPage--; // Revert page increment
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Search transactions
  Future<void> searchTransactions(String query) async {
    _searchQuery = query;
    await fetchTransactionHistory(refresh: true);
  }

  /// Change sort order
  Future<void> changeSortOrder(String order) async {
    _sortOrder = order;
    await fetchTransactionHistory(refresh: true);
  }

  /// Calculate total credit amount
  double get totalCreditAmount {
    return creditTransactions.fold(0.0, (sum, transaction) {
      final amount = double.tryParse(transaction.amount ?? '0') ?? 0.0;
      return sum + amount;
    });
  }

  /// Calculate total debit amount
  double get totalDebitAmount {
    return debitTransactions.fold(0.0, (sum, transaction) {
      final amount = double.tryParse(transaction.amount ?? '0') ?? 0.0;
      return sum + amount;
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearTransactions() {
    _transactions.clear();
    _currentPage = 1;
    _hasMoreData = true;
    _searchQuery = '';
    notifyListeners();
  }
}