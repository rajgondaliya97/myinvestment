class TransactionHistoryModel {
  int? status;
  String? message;
  List<TransactionHistoryModelData>? data;
  Pagination? pagination;

  TransactionHistoryModel(
      {this.status, this.message, this.data, this.pagination});

  TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <TransactionHistoryModelData>[];
      json['data'].forEach((v) {
        data!.add(new TransactionHistoryModelData.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class TransactionHistoryModelData {
  String? type;
  String? category;
  String? amount;
  String? balanceAfter;
  String? transactionReference;
  String? description;
  String? createdAt;

  TransactionHistoryModelData(
      {this.type,
        this.category,
        this.amount,
        this.balanceAfter,
        this.transactionReference,
        this.description,
        this.createdAt});

  TransactionHistoryModelData.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    category = json['category'];
    amount = json['amount'];
    balanceAfter = json['balance_after'];
    transactionReference = json['transaction_reference'];
    description = json['description'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['category'] = this.category;
    data['amount'] = this.amount;
    data['balance_after'] = this.balanceAfter;
    data['transaction_reference'] = this.transactionReference;
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    return data;
  }
}

class Pagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Pagination({this.currentPage, this.lastPage, this.perPage, this.total});

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    data['last_page'] = this.lastPage;
    data['per_page'] = this.perPage;
    data['total'] = this.total;
    return data;
  }
}
