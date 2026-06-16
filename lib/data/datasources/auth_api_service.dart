import 'package:dio/dio.dart';
import '../../core/app_urls/app_urls.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/otp_verify_request_model.dart';
import '../models/resend_otp_response_model.dart';
import '../models/user_model.dart';



class AuthApiService {
  final Dio dio;

  AuthApiService(this.dio);

  Future<LoginResponseModel> sendOtp(LoginRequestModel request) async {
    try {
      final response = await dio.post(
        AppUrls.login,
        data: request.toJson(),
      );
      if (response.statusCode == 200 && response.data['status'] == 200) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to send OTP');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> verifyOtp(OtpVerifyRequestModel request) async {
    try {
      final response = await dio.post(
        AppUrls.otpVerification,
        data: request.toJson(),
      );
      if (response.statusCode == 200 && response.data['status'] == 200) {
        final List<dynamic> resultList = response.data['result'];
        if (resultList.isNotEmpty) {
          return UserModel.fromJson(resultList.first);
        } else {
          throw Exception('No user data found');
        }
      } else {
        throw Exception(response.data['message'] ?? 'OTP verification failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ResendOtpResponseModel> resendOtp(int doctorId, String type) async {
    try {
      final response = await dio.post(
        AppUrls.resendOtp,
        data: {
          'doctor_id': doctorId,
          'type': type,
        },
      );
      if (response.statusCode == 200 && response.data['status'] == 200) {
        return ResendOtpResponseModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Resend OTP failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return error.response?.data['message'] ?? 'Server error occurred';
    } else {
      return error.message ?? 'Network error';
    }
  }
}