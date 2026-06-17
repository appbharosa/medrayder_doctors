import '../../data/models/create_room_request_model.dart';
import '../../data/models/create_room_response_model.dart';
import '../../data/models/join_room_request_model.dart';
import '../../data/models/join_room_response_model.dart';

abstract class CallRepository {
  Future<CreateRoomResponseModel> createRoom(CreateRoomRequestModel request);
  Future<JoinRoomResponseModel> joinRoom(JoinRoomRequestModel request);
}