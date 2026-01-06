class AddWalletBalanceModel {
  int? status;
  String? message;
  AddWalletBalanceModelData? data;

  AddWalletBalanceModel({this.status, this.message, this.data});

  AddWalletBalanceModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new AddWalletBalanceModelData.fromJson(json['data']) : null;
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

class AddWalletBalanceModelData {
  int? userId;
  int? balance;

  AddWalletBalanceModelData({this.userId, this.balance});

  AddWalletBalanceModelData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    balance = json['balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['balance'] = this.balance;
    return data;
  }
}
