import 'package:equatable/equatable.dart';
import '../../../data/models/bank_detail_model.dart';

abstract class BankState extends Equatable {
  const BankState();
  @override
  List<Object?> get props => [];
}

class BankInitial extends BankState {}

class BankLoading extends BankState {}

class BankLoaded extends BankState {
  final List<BankDetailModel> details;
  const BankLoaded(this.details);
  @override
  List<Object?> get props => [details];
}

class BankOperationSuccess extends BankState {
  final String message;
  const BankOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class BankError extends BankState {
  final String error;
  const BankError(this.error);
  @override
  List<Object?> get props => [error];
}