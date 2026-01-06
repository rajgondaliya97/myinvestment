class WithdrawBalanceModel {
  int? status;
  String? message;
  WithdrawBalanceModelData? data;

  WithdrawBalanceModel({this.status, this.message, this.data});

  WithdrawBalanceModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new WithdrawBalanceModelData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class WithdrawBalanceModelData {
  int? userId;
  int? amount;
  int? remainingBalance;
  String? transactionId;

  WithdrawBalanceModelData({
    this.userId,
    this.amount,
    this.remainingBalance,
    this.transactionId,
  });

  WithdrawBalanceModelData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    amount = json['amount'];
    remainingBalance = json['remaining_balance'];
    transactionId = json['transaction_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['amount'] = this.amount;
    data['remaining_balance'] = this.remainingBalance;
    data['transaction_id'] = this.transactionId;
    return data;
  }
}