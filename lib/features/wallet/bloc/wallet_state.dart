import 'package:equatable/equatable.dart';
import '../../../data/models/wallet_response_model.dart';

abstract class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletHistoryLoading extends WalletState {}

class WalletHistoryLoaded extends WalletState {
  final WalletResponseModel data;

  const WalletHistoryLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class WalletError extends WalletState {
  final String error;

  const WalletError(this.error);

  @override
  List<Object?> get props => [error];
}

class WalletDebitLoading extends WalletState {}

class WalletDebitSuccess extends WalletState {
  final String message;

  const WalletDebitSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class WalletDebitFailure extends WalletState {
  final String error;

  const WalletDebitFailure(this.error);

  @override
  List<Object?> get props => [error];
}