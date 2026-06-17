import 'package:equatable/equatable.dart';
import '../../../data/models/create_room_request_model.dart';
import '../../../data/models/join_room_request_model.dart';

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

class JoinVideoCall extends CallEvent {
  final JoinRoomRequestModel request;

  const JoinVideoCall(this.request);
  @override
  List<Object?> get props => [request];
}