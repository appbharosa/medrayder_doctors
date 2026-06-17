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
  final String roomId;
  final String callId;

  CreateRoomResult({required this.roomId, required this.callId});

  factory CreateRoomResult.fromJson(Map<String, dynamic> json) {
    return CreateRoomResult(
      roomId: json['room_id']?.toString() ?? '',
      callId: json['call_id']?.toString() ?? '',
    );
  }
}