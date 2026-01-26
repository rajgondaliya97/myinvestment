class GetWalletBalanceModel {
  int? status;
  String? message;
  GetWalletBalanceModelData? data;

  GetWalletBalanceModel({this.status, this.message, this.data});

  GetWalletBalanceModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new GetWalletBalanceModelData.fromJson(json['data']) : null;
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

class GetWalletBalanceModelData {
  dynamic balance;
  dynamic lockedBalance;

  GetWalletBalanceModelData({this.balance, this.lockedBalance});

  GetWalletBalanceModelData.fromJson(Map<String, dynamic> json) {
    balance = json['balance'];
    lockedBalance = json['locked_balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['balance'] = this.balance;
    data['locked_balance'] = this.lockedBalance;
    return data;
  }
}
