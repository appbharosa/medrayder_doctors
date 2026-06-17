class JoinRoomRequestModel {
  final String roomId;
  final String callId;

  JoinRoomRequestModel({required this.roomId, required this.callId});

  Map<String, dynamic> toJson() => {
    'room_id': roomId,
    'call_id': callId,
  };
}