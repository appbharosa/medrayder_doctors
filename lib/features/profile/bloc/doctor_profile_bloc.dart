import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/doctor_profile_repository.dart';
import 'doctor_profile_event.dart';
import 'doctor_profile_state.dart';

class DoctorProfileBloc extends Bloc<DoctorProfileEvent, DoctorProfileState> {
  final DoctorProfileRepository repository;

  DoctorProfileBloc({required this.repository}) : super(DoctorProfileInitial()) {
    on<FetchDoctorProfile>(_onFetch);
    on<UpdateDoctorProfile>(_onUpdate);
  }

  Future<void> _onFetch(FetchDoctorProfile event, Emitter<DoctorProfileState> emit) async {
    emit(DoctorProfileLoading());
    try {
      final profile = await repository.getProfile();
      emit(DoctorProfileLoaded(profile));
    } catch (e) {
      emit(DoctorProfileError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateDoctorProfile event, Emitter<DoctorProfileState> emit) async {
    emit(DoctorProfileLoading());
    try {
      final response = await repository.updateProfile(event.request);
      // After update, fetch the latest profile
      final updatedProfile = await repository.getProfile();
      emit(DoctorProfileLoaded(updatedProfile));
      emit(DoctorProfileUpdateSuccess(response['message'] ?? 'Profile updated successfully'));
    } catch (e) {
      emit(DoctorProfileError(e.toString()));
    }
  }
}