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

  // New State for filtering by source (0: Self, 1: Referral, null: All)
  int? _selectedSource;

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
  int? get selectedSource => _selectedSource;
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
// inside transaction_controller.dart

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
  /// Fetch transaction history (first page or refresh)
  /// Added source parameter to support the new dropdown
  Future<void> fetchTransactionHistory({bool refresh = false, int? source}) async {
    if (refresh) {
      _currentPage = 1;
      _transactions.clear();
      _hasMoreData = true;
      // Update the internal source state if a new one is provided
      if (source != undefined) _selectedSource = source;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📡 Fetching transaction history - Page: $_currentPage, Source: $_selectedSource');

      final response = await transactionRepository.getTransactionHistory(
        limit: _perPage,
        page: _currentPage,
        search: _searchQuery,
        sort: _sortOrder,
        isEarning: _selectedSource.toString(), // Passing the source to the repository
      );

      if (response.status == 1 && response.data != null) {
        if (refresh) {
          _transactions = response.data!;
        } else {
          _transactions.addAll(response.data!);
        }

        if (response.pagination != null) {
          _currentPage = response.pagination!.currentPage ?? 1;
          _lastPage = response.pagination!.lastPage ?? 1;
          _perPage = response.pagination!.perPage ?? 10;
          _total = response.pagination!.total ?? 0;
          _hasMoreData = _currentPage < _lastPage;
        }
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Failed to fetch transactions';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
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
      final response = await transactionRepository.getTransactionHistory(
        limit: _perPage,
        page: _currentPage,
        search: _searchQuery,
        sort: _sortOrder,
        isEarning: _selectedSource.toString(),
      );

      if (response.status == 1 && response.data != null) {
        _transactions.addAll(response.data!);

        if (response.pagination != null) {
          _currentPage = response.pagination!.currentPage ?? _currentPage;
          _lastPage = response.pagination!.lastPage ?? _lastPage;
          _hasMoreData = _currentPage < _lastPage;
        }
      }
    } on ApiException catch (e) {
      _currentPage--;
    } catch (e) {
      _currentPage--;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Search transactions
  Future<void> searchTransactions(String query) async {
    _searchQuery = query;
    await fetchTransactionHistory(refresh: true);
  }

  void clearTransactions() {
    _transactions.clear();
    _currentPage = 1;
    _hasMoreData = true;
    _searchQuery = '';
    _selectedSource = null; // Reset filter
    notifyListeners();
  }
}

// Constant helper to check for optional parameter passing
const undefined = Object();