// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoctorProfileModel _$DoctorProfileModelFromJson(Map<String, dynamic> json) =>
    DoctorProfileModel(
      id: (json['id'] as num).toInt(),
      uniqueId: json['unique_id'] as String,
      name: json['name'] as String,
      mobile: json['mobile'] as String,
      specialization: json['specialization'] as String,
      description: json['description'] as String,
      offlineFee: (json['offline_fee'] as num).toInt(),
      onlineFee: (json['online_fee'] as num).toInt(),
      consultType: json['consult_type'] as String,
      image: json['image'] as String,
      profileImage: json['profile_image'] as String,
      status: (json['status'] as num).toInt(),
      createdOn: json['created_on'] as String,
      modifiedOn: json['modified_on'] as String,
    );

Map<String, dynamic> _$DoctorProfileModelToJson(DoctorProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unique_id': instance.uniqueId,
      'name': instance.name,
      'mobile': instance.mobile,
      'specialization': instance.specialization,
      'description': instance.description,
      'offline_fee': instance.offlineFee,
      'online_fee': instance.onlineFee,
      'consult_type': instance.consultType,
      'image': instance.image,
      'profile_image': instance.profileImage,
      'status': instance.status,
      'created_on': instance.createdOn,
      'modified_on': instance.modifiedOn,
    };
