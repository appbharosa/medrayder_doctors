class CreateRoomRequestModel {
  final String type;
  final int doctorId;
  final int patientId;
  final int appointmentId;
  final int duration; // in minutes

  CreateRoomRequestModel({
    required this.type,
    required this.doctorId,
    required this.patientId,
    required this.appointmentId,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'doctor_id': doctorId,
    'patient_id': patientId,
    'appointment_id': appointmentId,
    'duration': duration,
  };
}