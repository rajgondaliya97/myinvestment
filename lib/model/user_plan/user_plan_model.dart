class UserPlanModel {
  int? status;
  List<UserPlanModelData>? data;
  Pagination? pagination;

  UserPlanModel({this.status, this.data, this.pagination});

  UserPlanModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <UserPlanModelData>[];
      json['data'].forEach((v) {
        data!.add(new UserPlanModelData.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class UserPlanModelData {
  int? userPlanId;
  String? planName;
  int? planId;
  int? amount;
  int? dailyInterest;
  int? totalInterest;
  String? startDate;
  String? endDate;
  String? status;

  UserPlanModelData(
      {this.userPlanId,
        this.planName,
        this.planId,
        this.amount,
        this.dailyInterest,
        this.totalInterest,
        this.startDate,
        this.endDate,
        this.status});

  UserPlanModelData.fromJson(Map<String, dynamic> json) {
    userPlanId = json['user_plan_id'];
    planName = json['plan_name'];
    planId = json['plan_id'];
    amount = json['amount'];
    dailyInterest = json['daily_interest'];
    totalInterest = json['total_interest'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_plan_id'] = this.userPlanId;
    data['plan_name'] = this.planName;
    data['plan_id'] = this.planId;
    data['amount'] = this.amount;
    data['daily_interest'] = this.dailyInterest;
    data['total_interest'] = this.totalInterest;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['status'] = this.status;
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
