class LoginResponseModel {
  final int status;
  final String message;
  final ResultData result;

  LoginResponseModel({
    required this.status,
    required this.message,
    required this.result,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      status: json['status'],
      message: json['message'],
      result: ResultData.fromJson(json['result']),
    );
  }
}

class ResultData {
  final String message;
  final int doctorId;
  final String type;
  final int otp;

  ResultData({
    required this.message,
    required this.doctorId,
    required this.type,
    required this.otp,
  });

  factory ResultData.fromJson(Map<String, dynamic> json) {
    return ResultData(
      message: json['message'],
      doctorId: json['doctor_id'],
      type: json['type'],
      otp: json['otp'],
    );
  }
}