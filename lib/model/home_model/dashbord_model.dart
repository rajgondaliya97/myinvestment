class DashboardDataModel {
  dynamic balance;
  dynamic activePlans;
  dynamic totalWithdrawalsApprove;
  dynamic totalWithdrawals;

  DashboardDataModel(
      {this.balance,
        this.activePlans,
        this.totalWithdrawalsApprove,
        this.totalWithdrawals});

  DashboardDataModel.fromJson(Map<String, dynamic> json) {
    balance = json['balance'];
    activePlans = json['active_plans'];
    totalWithdrawalsApprove = json['total_withdrawals_approve'];
    totalWithdrawals = json['total_withdrawals'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['balance'] = this.balance;
    data['active_plans'] = this.activePlans;
    data['total_withdrawals_approve'] = this.totalWithdrawalsApprove;
    data['total_withdrawals'] = this.totalWithdrawals;
    return data;
  }
}
