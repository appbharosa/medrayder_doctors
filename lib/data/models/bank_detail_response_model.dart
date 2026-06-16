import 'package:json_annotation/json_annotation.dart';
import 'bank_detail_model.dart';
part 'bank_detail_response_model.g.dart';



@JsonSerializable()
class BankDetailResponseModel {
  final int status;
  final String message;
  final dynamic result; // ✅ always dynamic

  BankDetailResponseModel({
    required this.status,
    required this.message,
    required this.result,
  });

  factory BankDetailResponseModel.fromJson(Map<String, dynamic> json) =>
      _$BankDetailResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$BankDetailResponseModelToJson(this);
}

/// Safe extension – handles both List and Map
extension BankDetailResponseExt on BankDetailResponseModel {
  List<BankDetailModel> get bankDetails {
    try {
      if (result == null) return [];

      // If it's a List – map each item
      if (result is List) {
        final list = result as List;
        return list
            .where((item) => item != null && item is Map<String, dynamic>)
            .map((item) => BankDetailModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // If it's a single Map – wrap in list
      if (result is Map<String, dynamic>) {
        return [BankDetailModel.fromJson(result)];
      }

      return [];
    } catch (e) {
      print('❌ BankDetail parsing error: $e');
      return [];
    }
  }
}