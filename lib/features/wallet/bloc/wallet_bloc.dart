import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository repository;

  WalletBloc({required this.repository}) : super(WalletInitial()) {
    on<FetchWalletHistory>(_onFetchHistory);
    on<RequestWalletDebit>(_onRequestDebit);
    on<ResetWalletDebitState>(_onResetDebitState);
  }

  Future<void> _onFetchHistory(FetchWalletHistory event, Emitter<WalletState> emit) async {
    emit(WalletHistoryLoading());
    try {
      final data = await repository.getWalletHistory(
        doctorId: event.doctorId,
        startDate: event.startDate,
        endDate: event.endDate,
        transactionType: event.transactionType,
      );
      emit(WalletHistoryLoaded(data));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onRequestDebit(RequestWalletDebit event, Emitter<WalletState> emit) async {
    emit(WalletDebitLoading());
    try {
      final response = await repository.requestDebit(event.request);
      if (response['status'] == 200) {
        emit(WalletDebitSuccess(response['message'] ?? 'Debit request successful'));
      } else {
        emit(WalletDebitFailure(response['message'] ?? 'Failed to process debit request'));
      }
    } catch (e) {
      emit(WalletDebitFailure(e.toString()));
    }
  }

  void _onResetDebitState(ResetWalletDebitState event, Emitter<WalletState> emit) {
    // Reset to initial state after showing success/failure
    emit(WalletInitial());
  }
}