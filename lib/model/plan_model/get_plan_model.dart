class GetPlanModel {
  int? status;
  String? message;
  List<GetPlanModelData>? data;

  GetPlanModel({this.status, this.message, this.data});

  GetPlanModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <GetPlanModelData>[];
      json['data'].forEach((v) {
        data!.add(new GetPlanModelData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GetPlanModelData {
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

  GetPlanModelData(
      {this.id,
        this.name,
        this.description,
        this.minAmount,
        this.maxAmount,
        this.dailyRoi,
        this.durationDays,
        this.totalReturn,
        this.status,
        this.type});

  GetPlanModelData.fromJson(Map<String, dynamic> json) {
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
    return data;
  }
}
