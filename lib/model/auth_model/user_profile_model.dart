class UserProfileModel {
  int? status;
  String? message;
  UserProfileModelData? data;

  UserProfileModel({this.status, this.message, this.data});

  UserProfileModel.fromJson(Map<String, dynamic> json) {
    status = json['status']; //
    message = json['message']; //
    data = json['data'] != null ? UserProfileModelData.fromJson(json['data']) : null; //
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status; //
    data['message'] = message; //
    if (this.data != null) {
      data['data'] = this.data!.toJson(); //
    }
    return data;
  }
}

class UserProfileModelData {
  int? id;
  String? firstName;
  String? lastName;
  dynamic name;        // Replaced Null? with dynamic
  String? email;
  dynamic phone;       // Replaced Null? with dynamic
  String? profile;
  dynamic country;     // Replaced Null? with dynamic
  dynamic address;     // Replaced Null? with dynamic
  dynamic idProof;     // Replaced Null? with dynamic
  dynamic walletBalance;
  String? role;
  bool? isVerified;
  String? referralCode;
  dynamic referredBy;  // Replaced Null? with dynamic
  dynamic lastLogin;   // Replaced Null? with dynamic
  String? createdAt;

  UserProfileModelData({
    this.id,
    this.firstName,
    this.lastName,
    this.name,
    this.email,
    this.phone,
    this.profile,
    this.country,
    this.address,
    this.idProof,
    this.walletBalance,
    this.role,
    this.isVerified,
    this.referralCode,
    this.referredBy,
    this.lastLogin,
    this.createdAt,
  });

  UserProfileModelData.fromJson(Map<String, dynamic> json) {
    id = json['id']; //
    firstName = json['first_name']; //
    lastName = json['last_name']; //
    name = json['name']; //
    email = json['email']; //
    phone = json['phone']; //
    profile = json['profile']; //
    country = json['country']; //
    address = json['address']; //
    idProof = json['id_proof']; //
    walletBalance = json['wallet_balance']; //
    role = json['role']; //
    isVerified = json['is_verified']; //
    referralCode = json['referral_code']; //
    referredBy = json['referred_by']; //
    lastLogin = json['last_login']; //
    createdAt = json['created_at']; //
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id; //
    data['first_name'] = firstName; //
    data['last_name'] = lastName; //
    data['name'] = name; //
    data['email'] = email; //
    data['phone'] = phone; //
    data['profile'] = profile; //
    data['country'] = country; //
    data['address'] = address; //
    data['id_proof'] = idProof; //
    data['wallet_balance'] = walletBalance; //
    data['role'] = role; //
    data['is_verified'] = isVerified; //
    data['referral_code'] = referralCode; //
    data['referred_by'] = referredBy; //
    data['last_login'] = lastLogin; //
    data['created_at'] = createdAt; //
    return data;
  }
}