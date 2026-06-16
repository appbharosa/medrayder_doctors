import 'package:equatable/equatable.dart';
import '../../../data/models/update_profile_request_model.dart';

abstract class DoctorProfileEvent extends Equatable {
  const DoctorProfileEvent();
  @override
  List<Object?> get props => [];
}

class FetchDoctorProfile extends DoctorProfileEvent {}

class UpdateDoctorProfile extends DoctorProfileEvent {
  final UpdateProfileRequestModel request;

  const UpdateDoctorProfile(this.request);
  @override
  List<Object?> get props => [request];
}