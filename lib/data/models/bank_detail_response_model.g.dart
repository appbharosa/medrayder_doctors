// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_detail_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankDetailResponseModel _$BankDetailResponseModelFromJson(
  Map<String, dynamic> json,
) => BankDetailResponseModel(
  status: (json['status'] as num).toInt(),
  message: json['message'] as String,
  result: json['result'],
);

Map<String, dynamic> _$BankDetailResponseModelToJson(
  BankDetailResponseModel instance,
) => <String, dynamic>{
  'status': instance.status,
  'message': instance.message,
  'result': instance.result,
};
