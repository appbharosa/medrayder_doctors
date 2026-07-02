import 'package:equatable/equatable.dart';
import '../../../../domain/entities/prescription_request.dart';

abstract class PrescriptionEvent extends Equatable {
  const PrescriptionEvent();
  @override
  List<Object> get props => [];
}

class AddPrescriptionEvent extends PrescriptionEvent {
  final PrescriptionRequest request;
  const AddPrescriptionEvent(this.request);
}

class FetchPrescriptionEvent extends PrescriptionEvent {
  final String bookingId;
  final String doctorType;
  const FetchPrescriptionEvent({required this.bookingId, required this.doctorType});
}