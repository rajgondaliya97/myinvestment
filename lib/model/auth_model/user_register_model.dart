class UserRegisterModel {
  String? firstName;
  String? lastName;
  String? password;
  String? email;
  String? referralCode;

  UserRegisterModel(
      {this.firstName,
        this.lastName,
        this.password,
        this.email,
        this.referralCode});

  UserRegisterModel.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    password = json['password'];
    email = json['email'];
    referralCode = json['referral_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['password'] = this.password;
    data['email'] = this.email;
    data['referral_code'] = this.referralCode;
    return data;
  }
}
