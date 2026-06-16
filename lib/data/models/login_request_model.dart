class LoginRequestModel {
  final String phone;
  final String type;

  LoginRequestModel({required this.phone, required this.type});

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'type': type,
  };
}