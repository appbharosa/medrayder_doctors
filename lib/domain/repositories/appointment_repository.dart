import '../../data/models/appointment_response_model.dart';

abstract class AppointmentRepository {
  Future<AppointmentResponseModel> getActiveAppointments({
    required String type,
    int limit = 10,
    int offset = 0,
  });
}