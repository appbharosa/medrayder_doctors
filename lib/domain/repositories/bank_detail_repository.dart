import '../../data/models/bank_detail_model.dart';
import '../../data/models/bank_detail_request_model.dart';

abstract class BankRepository {
  Future<List<BankDetailModel>> getBankDetails();
  Future<BankDetailModel> addBankDetails(BankDetailRequestModel request);
  Future<BankDetailModel> updateBankDetails(int id, BankDetailRequestModel request);
}