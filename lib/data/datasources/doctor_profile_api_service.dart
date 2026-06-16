import 'package:dio/dio.dart';

import '../../core/app_urls/app_urls.dart';
import '../models/doctor_profile_model.dart';
import '../models/update_profile_request_model.dart';


class DoctorProfileApiService {
  final Dio dio;

  DoctorProfileApiService(this.dio);

  Future<DoctorProfileModel> getProfile() async {
    try {
      final response = await dio.get(AppUrls.doctorProfile);
      if (response.statusCode == 200 && response.data['status'] == 200) {
        return DoctorProfileModel.fromJson(response.data['result']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load profile');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile(UpdateProfileRequestModel request) async {
    try {
      final response = await dio.post(
        AppUrls.updateProfile,
        data: request.toJson(),
      );
      if (response.statusCode == 200 && response.data['status'] == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update profile');
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