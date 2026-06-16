
class OtpVerifyRequestModel {
  final int doctorId;
  final String otp;
  final String type;

  OtpVerifyRequestModel({
    required this.doctorId,
    required this.otp,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'doctor_id': doctorId,
    'otp': otp,
    'type': type,
  };
}