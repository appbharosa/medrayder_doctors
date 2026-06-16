import 'package:equatable/equatable.dart';
import '../../../../data/models/login_response_model.dart';

abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoginResponseModel response;
  const LoginSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class LoginFailure extends LoginState {
  final String error;
  const LoginFailure(this.error);
  @override
  List<Object?> get props => [error];
}