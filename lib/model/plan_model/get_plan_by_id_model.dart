class GetPlanByIdModel {
  int? status;
  String? message;
  GetPlanByIdModelData? data;

  GetPlanByIdModel({this.status, this.message, this.data});

  GetPlanByIdModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new GetPlanByIdModelData.fromJson(json['data']) : null;
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

class GetPlanByIdModelData {
  int? id;
  String? name;
  dynamic description;
  String? minAmount;
  String? maxAmount;
  String? dailyRoi;
  int? durationDays;
  dynamic totalReturn;
  String? status;
  String? type;
  String? createdAt;
  String? updatedAt;

  GetPlanByIdModelData(
      {this.id,
        this.name,
        this.description,
        this.minAmount,
        this.maxAmount,
        this.dailyRoi,
        this.durationDays,
        this.totalReturn,
        this.status,
        this.type,
        this.createdAt,
        this.updatedAt});

  GetPlanByIdModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    minAmount = json['min_amount'];
    maxAmount = json['max_amount'];
    dailyRoi = json['daily_roi'];
    durationDays = json['duration_days'];
    totalReturn = json['total_return'];
    status = json['status'];
    type = json['type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['min_amount'] = this.minAmount;
    data['max_amount'] = this.maxAmount;
    data['daily_roi'] = this.dailyRoi;
    data['duration_days'] = this.durationDays;
    data['total_return'] = this.totalReturn;
    data['status'] = this.status;
    data['type'] = this.type;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
