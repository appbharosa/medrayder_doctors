import 'package:equatable/equatable.dart';

import '../../../data/models/prescription_response_model.dart';

abstract class PrescriptionState extends Equatable {
  const PrescriptionState();
  @override
  List<Object> get props => [];
}

class PrescriptionInitial extends PrescriptionState {}

class PrescriptionLoading extends PrescriptionState {}

class PrescriptionSuccess extends PrescriptionState {}

class PrescriptionError extends PrescriptionState {
  final String message;
  const PrescriptionError(this.message);
}
class PrescriptionFetched extends PrescriptionState {
  final PrescriptionResponseModel prescription;
  const PrescriptionFetched(this.prescription);
}