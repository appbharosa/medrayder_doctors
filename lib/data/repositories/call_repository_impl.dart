import '../../domain/repositories/call_repository.dart';
import '../datasources/call_api_service.dart';
import '../models/create_room_request_model.dart';
import '../models/create_room_response_model.dart';
import '../models/join_room_request_model.dart';
import '../models/join_room_response_model.dart';

class CallRepositoryImpl implements CallRepository {
  final CallApiService apiService;

  CallRepositoryImpl({required this.apiService});

  @override
  Future<CreateRoomResponseModel> createRoom(CreateRoomRequestModel request) {
    return apiService.createRoom(request);
  }

  @override
  Future<Map<String, dynamic>> endCall(String roomId, String callId) {
    return apiService.endCall(roomId, callId);
  }
}