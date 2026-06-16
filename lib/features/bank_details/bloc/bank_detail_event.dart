import 'package:equatable/equatable.dart';
import '../../../data/models/bank_detail_request_model.dart';


abstract class BankEvent extends Equatable {
  const BankEvent();
  @override
  List<Object?> get props => [];
}

class FetchBankDetails extends BankEvent {}

class AddBankDetail extends BankEvent {
  final BankDetailRequestModel request;
  const AddBankDetail(this.request);
  @override
  List<Object?> get props => [request];
}

class UpdateBankDetail extends BankEvent {
  final int id;
  final BankDetailRequestModel request;
  const UpdateBankDetail(this.id, this.request);
  @override
  List<Object?> get props => [id, request];
}