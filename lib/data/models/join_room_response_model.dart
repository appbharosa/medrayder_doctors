class JoinRoomResponseModel {
  final int status;
  final String message;
  final JoinRoomResult result;

  JoinRoomResponseModel({
    required this.status,
    required this.message,
    required this.result,
  });

  factory JoinRoomResponseModel.fromJson(Map<String, dynamic> json) {
    return JoinRoomResponseModel(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      result: JoinRoomResult.fromJson(json['result'] ?? {}),
    );
  }
}

class JoinRoomResult {
  final String token;
  final String roomId;

  JoinRoomResult({required this.token, required this.roomId});

  factory JoinRoomResult.fromJson(Map<String, dynamic> json) {
    return JoinRoomResult(
      token: json['token']?.toString() ?? '',
      roomId: json['room_id']?.toString() ?? '',
    );
  }
}