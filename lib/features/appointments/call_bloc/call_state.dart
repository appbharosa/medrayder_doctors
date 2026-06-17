import 'package:equatable/equatable.dart';
import '../../../data/models/create_room_response_model.dart';
import '../../../data/models/join_room_response_model.dart';

abstract class CallState extends Equatable {
  const CallState();
  @override
  List<Object?> get props => [];
}

class CallInitial extends CallState {}

class CallCreatingRoom extends CallState {}

class CallRoomCreated extends CallState {
  final CreateRoomResponseModel data;

  const CallRoomCreated(this.data);
  @override
  List<Object?> get props => [data];
}

class CallJoiningRoom extends CallState {}

class CallRoomJoined extends CallState {
  final JoinRoomResponseModel data;

  const CallRoomJoined(this.data);
  @override
  List<Object?> get props => [data];
}

class CallError extends CallState {
  final String error;

  const CallError(this.error);
  @override
  List<Object?> get props => [error];
}