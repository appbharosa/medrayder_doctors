import 'package:dio/dio.dart';

import '../../core/app_urls/app_urls.dart';
import '../models/create_room_request_model.dart';
import '../models/create_room_response_model.dart';
import '../models/join_room_request_model.dart';
import '../models/join_room_response_model.dart';


class CallApiService {
  final Dio dio;

  CallApiService(this.dio);

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

  Future<JoinRoomResponseModel> joinRoom(JoinRoomRequestModel request) async {
    try {
      final response = await dio.post(
        AppUrls.joinRoom,
        data: request.toJson(),
      );
      if (response.statusCode == 200 && response.data['status'] == 200) {
        return JoinRoomResponseModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to join room');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  Future<Map<String, dynamic>> endCall(String roomId, String callId) async {
    try {
      final response = await dio.delete(
        '${AppUrls.endCall}/$roomId',
        data: {'room_id': roomId, 'call_id': callId},
      );
      // Even if status is 404, we can still treat as success if we want? But we'll treat non-200 as error.
      if (response.statusCode == 200 || response.statusCode == 404) {
        // For 404, we might still want to close the call, so return success.
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to end call: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e);
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