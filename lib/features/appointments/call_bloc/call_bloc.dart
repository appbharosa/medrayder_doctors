import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/call_repository.dart';
import 'call_event.dart';
import 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  final CallRepository repository;

  CallBloc({required this.repository}) : super(CallInitial()) {
    on<StartVideoCall>(_onStartVideoCall);
    on<EndCall>(_onEndCall);
    on<ResetCallState>(_onReset);
  }

  Future<void> _onStartVideoCall(StartVideoCall event, Emitter<CallState> emit) async {
    emit(CallCreatingRoom());
    try {
      final response = await repository.createRoom(event.request);
      emit(CallRoomCreated(response.result));
    } catch (e) {
      emit(CallError(e.toString()));
    }
  }

  Future<void> _onEndCall(EndCall event, Emitter<CallState> emit) async {
    emit(CallEnding());
    try {
      final response = await repository.endCall(event.roomId, event.callId);
      emit(CallEnded(response['message'] ?? 'Call ended successfully'));
    } catch (e) {
      emit(CallError(e.toString()));
    }
  }

  void _onReset(ResetCallState event, Emitter<CallState> emit) {
    emit(CallInitial());
  }
}