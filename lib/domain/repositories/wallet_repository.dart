import '../../data/models/wallet_debit_request_model.dart';
import '../../data/models/wallet_response_model.dart';

abstract class WalletRepository {
  Future<WalletResponseModel> getWalletHistory({
    required int doctorId,
    required String type,
    String? startDate,
    String? endDate,
    String? transactionType,
  });
  Future<Map<String, dynamic>> requestDebit(WalletDebitRequestModel request);
}