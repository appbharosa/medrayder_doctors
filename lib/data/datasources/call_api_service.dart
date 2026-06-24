import 'package:dio/dio.dart';

import '../../core/app_urls/app_urls.dart';
import '../models/create_room_request_model.dart';
import '../models/create_room_response_model.dart';


class CallApiService {
  final Dio dio;

  CallApiService(this.dio);

  // Only one API call needed – returns both tokens
  Future<CreateRoomResponseModel> createRoom(CreateRoomRequestModel request) async {
    try {
      final response = await dio.post(
        AppUrls.createRoom,
        data: request.toJson(),
      );
      if (response.statusCode == 200 && response.data['status'] == 200) {
        return CreateRoomResponseModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create room');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> endCall(String roomId, String callId) async {
    print('🔴 END CALL REQUEST: roomId=$roomId, callId=$callId');
    print('🔴 URL: ${AppUrls.endCall}/$roomId');

    try {
      // ✅ Only URL – no body (room_id already in path)
      final response = await dio.delete(
        '${AppUrls.endCall}/$roomId',
      );
      print('🔴 END CALL RESPONSE: status=${response.statusCode}');
      print('🔴 END CALL RESPONSE DATA: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 404) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to end call: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // ... error logging ...
      throw _handleError(e);
    } catch (e, stack) {
      // ...
      rethrow;
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return error.response?.data['message'] ?? 'Server error occurred';
    } else {
      return error.message ?? 'Network error';
    }
  }
}