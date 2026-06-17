import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/call_repository.dart';
import 'call_event.dart';
import 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  final CallRepository repository;

  CallBloc({required this.repository}) : super(CallInitial()) {
    on<StartVideoCall>(_onStartVideoCall);
    on<JoinVideoCall>(_onJoinVideoCall);
  }

  Future<void> _onStartVideoCall(StartVideoCall event, Emitter<CallState> emit) async {
    emit(CallCreatingRoom());
    try {
      final response = await repository.createRoom(event.request);
      emit(CallRoomCreated(response));
    } catch (e) {
      emit(CallError(e.toString()));
    }
  }

  Future<void> _onJoinVideoCall(JoinVideoCall event, Emitter<CallState> emit) async {
    emit(CallJoiningRoom());
    try {
      final response = await repository.joinRoom(event.request);
      emit(CallRoomJoined(response));
    } catch (e) {
      emit(CallError(e.toString()));
    }
  }
}