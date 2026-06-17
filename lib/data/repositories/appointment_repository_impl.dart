import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_api_service.dart';
import '../models/appointment_response_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentApiService apiService;

  AppointmentRepositoryImpl({required this.apiService});

  @override
  Future<AppointmentResponseModel> getActiveAppointments({
    required String type,
    int limit = 10,
    int offset = 0,
  }) {
    return apiService.getActiveAppointments(
      type: type,
      limit: limit,
      offset: offset,
    );
  }
}