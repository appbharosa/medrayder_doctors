import '../../domain/repositories/bank_detail_repository.dart';
import '../datasources/bank_detail_api_service.dart';
import '../models/bank_detail_model.dart';
import '../models/bank_detail_request_model.dart';
import '../models/bank_detail_response_model.dart';

class BankRepositoryImpl implements BankRepository {
  final BankApiService apiService;

  BankRepositoryImpl({required this.apiService});

  @override
  Future<List<BankDetailModel>> getBankDetails() async {
    try {
      final response = await apiService.getBankDetailsRaw();
      print('✅ API response received');

      if (response['status'] != 200) {
        throw Exception(response['message'] ?? 'Failed to load bank details');
      }

      final result = response['result'];
      if (result == null) return [];

      if (result is List) {
        return result
            .where((item) => item is Map<String, dynamic>)
            .map((item) => BankDetailModel.fromJson(item))
            .toList();
      } else if (result is Map<String, dynamic>) {
        return [BankDetailModel.fromJson(result)];
      } else {
        return [];
      }
    } catch (e, stack) {
      print('❌ BankDetails parsing error: $e');
      print('Stack: $stack');
      rethrow;
    }
  }

  @override
  Future<BankDetailModel> addBankDetails(BankDetailRequestModel request) async {
    final response = await apiService.addBankDetailsRaw(request.toJson());
    if (response['status'] != 200) {
      throw Exception(response['message'] ?? 'Failed to add bank details');
    }
    final result = response['result'];
    if (result is Map<String, dynamic>) {
      return BankDetailModel.fromJson(result);
    } else if (result is List && result.isNotEmpty) {
      return BankDetailModel.fromJson(result.first as Map<String, dynamic>);
    } else {
      throw Exception('No bank detail returned after add');
    }
  }

  @override
  Future<BankDetailModel> updateBankDetails(int id, BankDetailRequestModel request) async {
    final response = await apiService.updateBankDetailsRaw(id, request.toJson());
    if (response['status'] != 200) {
      throw Exception(response['message'] ?? 'Failed to update bank details');
    }
    final result = response['result'];
    if (result is Map<String, dynamic>) {
      return BankDetailModel.fromJson(result);
    } else if (result is List && result.isNotEmpty) {
      return BankDetailModel.fromJson(result.first as Map<String, dynamic>);
    } else {
      throw Exception('No bank detail returned after update');
    }
  }
}