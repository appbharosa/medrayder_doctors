import 'package:equatable/equatable.dart';
import '../../../data/models/doctor_profile_model.dart';

abstract class DoctorProfileState extends Equatable {
  const DoctorProfileState();
  @override
  List<Object?> get props => [];
}

class DoctorProfileInitial extends DoctorProfileState {}

class DoctorProfileLoading extends DoctorProfileState {}

class DoctorProfileLoaded extends DoctorProfileState {
  final DoctorProfileModel profile;

  const DoctorProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

class DoctorProfileUpdateSuccess extends DoctorProfileState {
  final String message;

  const DoctorProfileUpdateSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class DoctorProfileError extends DoctorProfileState {
  final String error;

  const DoctorProfileError(this.error);
  @override
  List<Object?> get props => [error];
}