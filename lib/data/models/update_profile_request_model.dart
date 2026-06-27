import 'dart:io';
import 'package:dio/dio.dart';

class UpdateProfileRequestModel {
  final String? name;
  final int? exp;
  final String? qualification;
  final String? description;
  final String? consultType;
  final int? onlineFee;
  final int? offlineFee;
  final String? openTime;
  final String? closeTime;
  final File? image;

  UpdateProfileRequestModel({
    this.name,
    this.exp,
    this.qualification,
    this.description,
    this.consultType,
    this.onlineFee,
    this.offlineFee,
    this.openTime,
    this.closeTime,
    this.image,
  });

  FormData toFormData() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (exp != null) map['exp'] = exp;
    if (qualification != null) map['qualification'] = qualification;
    if (description != null) map['description'] = description;
    if (consultType != null) map['consult_type'] = consultType;
    if (onlineFee != null) map['online_fee'] = onlineFee;
    if (offlineFee != null) map['offline_fee'] = offlineFee;
    if (openTime != null) map['open_time'] = openTime;
    if (closeTime != null) map['close_time'] = closeTime;
    if (image != null) {
      map['image'] = MultipartFile.fromFileSync(image!.path);
    }
    return FormData.fromMap(map);
  }
}