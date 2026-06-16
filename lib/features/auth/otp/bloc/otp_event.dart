import 'package:equatable/equatable.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();
  @override
  List<Object?> get props => [];
}

class VerifyOtpRequested extends OtpEvent {
  final int doctorId;
  final String otp;
  final String type;

  const VerifyOtpRequested({
    required this.doctorId,
    required this.otp,
    required this.type,
  });

  @override
  List<Object?> get props => [doctorId, otp, type];
}

class ResendOtpRequested extends OtpEvent {
  final int doctorId;
  final String type;

  const ResendOtpRequested({required this.doctorId, required this.type});

  @override
  List<Object?> get props => [doctorId, type];
}