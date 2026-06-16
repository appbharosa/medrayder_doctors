
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_api_service.dart';
import '../models/wallet_debit_request_model.dart';
import '../models/wallet_response_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletApiService apiService;

  WalletRepositoryImpl({required this.apiService});

  @override
  Future<WalletResponseModel> getWalletHistory({
    required int doctorId,
    String? startDate,
    String? endDate,
    String? transactionType,
  }) {
    return apiService.getWalletHistory(
      doctorId: doctorId,
      startDate: startDate,
      endDate: endDate,
      transactionType: transactionType,
    );
  }

  @override
  Future<Map<String, dynamic>> requestDebit(WalletDebitRequestModel request) {
    return apiService.walletDebit(request);
  }
}