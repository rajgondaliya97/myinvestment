class LoginResponseModel {
  int? status;
  String? message;
  String? token;
  LoginResponseModelData? data;

  LoginResponseModel({this.status, this.message, this.token, this.data});

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    token = json['token'];
    data = json['data'] != null ? new LoginResponseModelData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['token'] = this.token;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? userId;
  LoginResponseModelData? user;
  int? activePlans;
  int? totalTransactions;
  int? totalWithdrawals;

  Data(
      {this.userId,
        this.user,
        this.activePlans,
        this.totalTransactions,
        this.totalWithdrawals});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    user = json['user'] != null ? new LoginResponseModelData.fromJson(json['user']) : null;
    activePlans = json['active_plans'];
    totalTransactions = json['total_transactions'];
    totalWithdrawals = json['total_withdrawals'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['active_plans'] = this.activePlans;
    data['total_transactions'] = this.totalTransactions;
    data['total_withdrawals'] = this.totalWithdrawals;
    return data;
  }
}

class LoginResponseModelData {
  int? id;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  String? role;
  dynamic country;
  dynamic address;
  dynamic idProof;
  String? referralCode;
  dynamic referredBy;
  String? walletBalance;
  String? investmentAmount;
  String? isVerified;
  dynamic lastLogin;
  String? createdAt;
  String? updatedAt;
  String? firstName;
  dynamic phone;
  String? lastName;

  LoginResponseModelData(
      {this.id,
        this.name,
        this.email,
        this.emailVerifiedAt,
        this.role,
        this.country,
        this.address,
        this.idProof,
        this.referralCode,
        this.referredBy,
        this.walletBalance,
        this.investmentAmount,
        this.isVerified,
        this.lastLogin,
        this.createdAt,
        this.updatedAt,
        this.firstName,
        this.phone,
        this.lastName});

  LoginResponseModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    role = json['role'];
    country = json['country'];
    address = json['address'];
    idProof = json['id_proof'];
    referralCode = json['referral_code'];
    referredBy = json['referred_by'];
    walletBalance = json['wallet_balance'];
    investmentAmount = json['investment_amount'];
    isVerified = json['is_verified'];
    lastLogin = json['last_login'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    firstName = json['first_name'];
    phone = json['phone'];
    lastName = json['last_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['role'] = this.role;
    data['country'] = this.country;
    data['address'] = this.address;
    data['id_proof'] = this.idProof;
    data['referral_code'] = this.referralCode;
    data['referred_by'] = this.referredBy;
    data['wallet_balance'] = this.walletBalance;
    data['investment_amount'] = this.investmentAmount;
    data['is_verified'] = this.isVerified;
    data['last_login'] = this.lastLogin;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['first_name'] = this.firstName;
    data['phone'] = this.phone;
    data['last_name'] = this.lastName;
    return data;
  }
}
