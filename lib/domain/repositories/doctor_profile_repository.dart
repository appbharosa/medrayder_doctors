import '../../data/models/doctor_profile_model.dart';
import '../../data/models/update_profile_request_model.dart';

abstract class DoctorProfileRepository {
  Future<DoctorProfileModel> getProfile();
  Future<Map<String, dynamic>> updateProfile(UpdateProfileRequestModel request);
}