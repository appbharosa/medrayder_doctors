import 'package:equatable/equatable.dart';
import '../../../../data/models/resend_otp_response_model.dart';
import '../../../../data/models/user_model.dart';

abstract class OtpState extends Equatable {
  const OtpState();
  @override
  List<Object?> get props => [];
}

class OtpInitial extends OtpState {}

class OtpVerifying extends OtpState {}
class ResendOtpLoading extends OtpState {}


class OtpVerificationSuccess extends OtpState {
  final UserModel user;
  const OtpVerificationSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class OtpVerificationFailure extends OtpState {
  final String error;
  const OtpVerificationFailure(this.error);
  @override
  List<Object?> get props => [error];
}

class OtpResendSuccess extends OtpState {
  final ResendOtpResponseModel response;
  const OtpResendSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class OtpResendFailure extends OtpState {
  final String error;
  const OtpResendFailure(this.error);
  @override
  List<Object?> get props => [error];
}