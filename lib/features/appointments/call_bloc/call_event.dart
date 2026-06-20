import 'package:equatable/equatable.dart';
import '../../../data/models/create_room_request_model.dart';

abstract class CallEvent extends Equatable {
  const CallEvent();
  @override
  List<Object?> get props => [];
}

class StartVideoCall extends CallEvent {
  final CreateRoomRequestModel request;
  const StartVideoCall(this.request);
  @override
  List<Object?> get props => [request];
}

class EndCall extends CallEvent {
  final String roomId;
  final String callId;
  const EndCall(this.roomId, this.callId);
  @override
  List<Object?> get props => [roomId, callId];
}

class ResetCallState extends CallEvent {}