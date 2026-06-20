import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/manager/user_manager.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api_service.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/otp_verify_request_model.dart';
import '../models/resend_otp_response_model.dart';
import '../models/user_model.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService apiService;
  final UserManager userManager;

  AuthRepositoryImpl({required this.apiService, required this.userManager});

  // In AuthRepositoryImpl
  Future<void> _registerFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && userManager.currentUser != null) {
        final deviceType = Platform.isAndroid ? 'android' : 'ios';
        await apiService.registerFcmToken(token, deviceType);
      }
    } catch (e) {
      print("FCM token registration failed: $e");
    }
  }

  @override
  Future<LoginResponseModel> sendOtp(String phone, String type) async {
    final request = LoginRequestModel(phone: phone, type: type);
    return await apiService.sendOtp(request);
  }

  @override
  Future<UserModel> verifyOtp(int doctorId, String otp, String type) async {
    final request = OtpVerifyRequestModel(doctorId: doctorId, otp: otp, type: type);
    final user = await apiService.verifyOtp(request);
    await saveUserData(user);
    await _registerFcmToken();
    return user;
  }
  @override
  Future<ResendOtpResponseModel> resendOtp(int doctorId, String type) {
    return apiService.resendOtp(doctorId, type);
  }

  @override
  Future<void> saveUserData(UserModel user) async {
    await userManager.saveUser(user);
  }

  @override
  Future<void> clearSession() async {
    await userManager.clearUser();
  }
}