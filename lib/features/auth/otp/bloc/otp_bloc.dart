import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/auth_repository.dart';
import 'otp_event.dart';
import 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final AuthRepository authRepository;

  OtpBloc({required this.authRepository}) : super(OtpInitial()) {
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<ResendOtpRequested>(_onResendOtpRequested);
  }

  Future<void> _onVerifyOtpRequested(
      VerifyOtpRequested event, Emitter<OtpState> emit) async {
    emit(OtpVerifying());
    try {
      final user = await authRepository.verifyOtp(
          event.doctorId, event.otp, event.type);
      emit(OtpVerificationSuccess(user));
    } catch (e) {
      emit(OtpVerificationFailure(e.toString()));
    }
  }

  Future<void> _onResendOtpRequested(
      ResendOtpRequested event,
      Emitter<OtpState> emit,
      ) async {
    emit(ResendOtpLoading());
    try {
      final response = await authRepository.resendOtp(event.doctorId, event.type);
      emit(OtpResendSuccess(response));
    } catch (e) {
      emit(OtpResendFailure(e.toString()));
    }
  }
}