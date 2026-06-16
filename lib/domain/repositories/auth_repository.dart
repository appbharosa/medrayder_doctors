import '../../data/models/login_response_model.dart';
import '../../data/models/resend_otp_response_model.dart';
import '../../data/models/user_model.dart';


abstract class AuthRepository {
  Future<LoginResponseModel> sendOtp(String phone, String type);
  Future<UserModel> verifyOtp(int doctorId, String otp, String type);
  Future<ResendOtpResponseModel> resendOtp(int doctorId, String type);
  Future<void> saveUserData(UserModel user);
  Future<void> clearSession();
}