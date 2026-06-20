import 'package:equatable/equatable.dart';
import '../../../data/models/create_room_response_model.dart';

abstract class CallState extends Equatable {
  const CallState();
  @override
  List<Object?> get props => [];
}

class CallInitial extends CallState {}

class CallCreatingRoom extends CallState {}

class CallRoomCreated extends CallState {
  final CreateRoomResult data;
  const CallRoomCreated(this.data);
  @override
  List<Object?> get props => [data];
}

class CallEnding extends CallState {}

class CallEnded extends CallState {
  final String message;
  const CallEnded(this.message);
  @override
  List<Object?> get props => [message];
}

class CallError extends CallState {
  final String error;
  const CallError(this.error);
  @override
  List<Object?> get props => [error];
}