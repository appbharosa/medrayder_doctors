import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class SendOtpRequested extends LoginEvent {
  final String phone;
  final String type;

  const SendOtpRequested({required this.phone, required this.type});

  @override
  List<Object?> get props => [phone, type];
}