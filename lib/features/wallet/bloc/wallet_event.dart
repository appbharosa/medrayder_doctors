import 'package:equatable/equatable.dart';
import '../../../data/models/wallet_debit_request_model.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => [];
}

class FetchWalletHistory extends WalletEvent {
  final int doctorId;
  final String? startDate;
  final String? endDate;
  final String? transactionType;

  const FetchWalletHistory({
    required this.doctorId,
    this.startDate,
    this.endDate,
    this.transactionType,
  });

  @override
  List<Object?> get props => [doctorId, startDate, endDate, transactionType];
}

class RequestWalletDebit extends WalletEvent {
  final WalletDebitRequestModel request;

  const RequestWalletDebit(this.request);

  @override
  List<Object?> get props => [request];
}

class ResetWalletDebitState extends WalletEvent {}