class ResendOtpResponseModel {
  final int status;
  final String message;
  final ResendOtpResult result;

  ResendOtpResponseModel({
    required this.status,
    required this.message,
    required this.result,
  });

  factory ResendOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return ResendOtpResponseModel(
      status: json['status'],
      message: json['message'],
      result: ResendOtpResult.fromJson(json['result']),
    );
  }
}

class ResendOtpResult {
  final String message;
  final String doctorId;
  final String type;
  final int otp;

  ResendOtpResult({
    required this.message,
    required this.doctorId,
    required this.type,
    required this.otp,
  });

  factory ResendOtpResult.fromJson(Map<String, dynamic> json) {
    return ResendOtpResult(
      message: json['message'],
      doctorId: json['doctor_id'].toString(),
      type: json['type'],
      otp: json['otp'],
    );
  }
}