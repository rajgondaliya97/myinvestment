class SingUpResponseModel {
  int? status;
  String? message;
  SingUpResponseModelData? data;

  SingUpResponseModel({this.status, this.message, this.data});

  SingUpResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new SingUpResponseModelData.fromJson(json['data']) : null;
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

class SingUpResponseModelData {
  int? userId;
  String? referralCode;
  int? referredBy;

  SingUpResponseModelData({this.userId, this.referralCode, this.referredBy});

  SingUpResponseModelData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    referralCode = json['referral_code'];
    referredBy = json['referred_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['referral_code'] = this.referralCode;
    data['referred_by'] = this.referredBy;
    return data;
  }
}
