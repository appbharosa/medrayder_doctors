class CreateRoomResponseModel {
  final int status;
  final String message;
  final CreateRoomResult result;

  CreateRoomResponseModel({
    required this.status,
    required this.message,
    required this.result,
  });

  factory CreateRoomResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateRoomResponseModel(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      result: CreateRoomResult.fromJson(json['result'] ?? {}),
    );
  }
}

class CreateRoomResult {
  final String callId;
  final String roomId;
  final String doctorToken;
  final String patientToken;
  final String? joinUrl;
  final int expiresIn;
  final bool notificationSent;

  CreateRoomResult({
    required this.callId,
    required this.roomId,
    required this.doctorToken,
    required this.patientToken,
    this.joinUrl,
    required this.expiresIn,
    required this.notificationSent,
  });

  factory CreateRoomResult.fromJson(Map<String, dynamic> json) {
    return CreateRoomResult(
      callId: json['call_id']?.toString() ?? '',
      roomId: json['room_id']?.toString() ?? '',
      doctorToken: json['doctor_token']?.toString() ?? '',
      patientToken: json['patient_token']?.toString() ?? '',
      joinUrl: json['join_url']?.toString(),
      expiresIn: json['expires_in'] ?? 0,
      notificationSent: json['notification_sent'] ?? false,
    );
  }
}