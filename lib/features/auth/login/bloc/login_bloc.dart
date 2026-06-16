import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(LoginInitial()) {
    on<SendOtpRequested>(_onSendOtpRequested);
  }

  Future<void> _onSendOtpRequested(
      SendOtpRequested event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final response = await authRepository.sendOtp(event.phone, event.type);
      emit(LoginSuccess(response));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}