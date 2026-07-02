import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/prescription_repository.dart';
import 'prescription_event.dart';
import 'prescription_state.dart';
import '../../../../core/errors/exceptions.dart';


class PrescriptionBloc extends Bloc<PrescriptionEvent, PrescriptionState> {
  final PrescriptionRepository repository;

  PrescriptionBloc({required this.repository}) : super(PrescriptionInitial()) {
    on<AddPrescriptionEvent>(_onAddPrescription);
    on<FetchPrescriptionEvent>(_onFetchPrescription);
  }
  Future<void> _onFetchPrescription(FetchPrescriptionEvent event, Emitter<PrescriptionState> emit) async {
    emit(PrescriptionLoading());
    try {
      final data = await repository.fetchPrescription(event.bookingId, event.doctorType);
      emit(PrescriptionFetched(data));
    } catch (e) {
      emit(PrescriptionError(e.toString()));
    }
  }
  Future<void> _onAddPrescription(AddPrescriptionEvent event, Emitter<PrescriptionState> emit) async {
    emit(PrescriptionLoading());
    try {
      await repository.addPrescription(event.request);
      emit(PrescriptionSuccess());
    } on ServerException catch (e) {
      // ✅ Extract the message from ServerException
      emit(PrescriptionError(e.message));
    } on Exception catch (e) {
      emit(PrescriptionError(e.toString()));
    }
  }
}