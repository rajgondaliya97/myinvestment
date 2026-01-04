class UpdateUserProfileModel {
  int? status;
  String? message;
  UpdateUserProfileModelData? data;

  UpdateUserProfileModel({this.status, this.message, this.data});

  UpdateUserProfileModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new UpdateUserProfileModelData.fromJson(json['data']) : null;
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

class UpdateUserProfileModelData {
  int? id;
  String? firstName;
  dynamic phone;
  String? lastName;
  dynamic profile;
  String? email;
  dynamic emailVerifiedAt;
  dynamic resetToken;
  dynamic resetTokenExpiry;
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

  UpdateUserProfileModelData(
      {this.id,
        this.firstName,
        this.phone,
        this.lastName,
        this.profile,
        this.email,
        this.emailVerifiedAt,
        this.resetToken,
        this.resetTokenExpiry,
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
        this.updatedAt});

  UpdateUserProfileModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    phone = json['phone'];
    lastName = json['last_name'];
    profile = json['profile'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    resetToken = json['reset_token'];
    resetTokenExpiry = json['reset_token_expiry'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['phone'] = this.phone;
    data['last_name'] = this.lastName;
    data['profile'] = this.profile;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['reset_token'] = this.resetToken;
    data['reset_token_expiry'] = this.resetTokenExpiry;
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
    return data;
  }
}
