import '../../domain/repositories/doctor_profile_repository.dart';
import '../datasources/doctor_profile_api_service.dart';
import '../models/doctor_profile_model.dart';
import '../models/update_profile_request_model.dart';

class DoctorProfileRepositoryImpl implements DoctorProfileRepository {
  final DoctorProfileApiService apiService;

  DoctorProfileRepositoryImpl({required this.apiService});

  @override
  Future<DoctorProfileModel> getProfile() {
    return apiService.getProfile();
  }

  @override
  Future<Map<String, dynamic>> updateProfile(UpdateProfileRequestModel request) {
    return apiService.updateProfile(request);
  }
}