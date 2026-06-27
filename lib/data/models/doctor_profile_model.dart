import 'package:json_annotation/json_annotation.dart';


class DoctorProfileModel {
  final int id;
  final String uniqueId;
  final String name;
  final String mobile;
  final String specialization;
  final String description;
  final int offlineFee;
  final int onlineFee;
  final String consultType;
  final String image;
  final String profileImage;
  final int status;
  final String createdOn;
  final String modifiedOn;
  // New fields
  final int exp;
  final String qualification;
  final String openTime;
  final String closeTime;

  DoctorProfileModel({
    required this.id,
    required this.uniqueId,
    required this.name,
    required this.mobile,
    required this.specialization,
    required this.description,
    required this.offlineFee,
    required this.onlineFee,
    required this.consultType,
    required this.image,
    required this.profileImage,
    required this.status,
    required this.createdOn,
    required this.modifiedOn,
    required this.exp,
    required this.qualification,
    required this.openTime,
    required this.closeTime,
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    final mobileValue = json['mobile'];
    final mobileString = mobileValue?.toString() ?? '';
    return DoctorProfileModel(
      id: json['id'] ?? 0,
      uniqueId: json['unique_id'] ?? '',
      name: json['name'] ?? '',
      mobile: mobileString,
      specialization: json['specialization'] ?? '',
      description: json['description'] ?? '',
      offlineFee: json['offline_fee'] ?? 0,
      onlineFee: json['online_fee'] ?? 0,
      consultType: json['consult_type'] ?? '',
      image: json['image'] ?? '',
      profileImage: json['profile_image'] ?? '',
      status: json['status'] ?? 0,
      createdOn: json['created_on'] ?? '',
      modifiedOn: json['modified_on'] ?? '',
      exp: json['exp'] ?? 0,
      qualification: json['qualification'] ?? '',
      openTime: json['open_time']?.toString() ?? '',
      closeTime: json['close_time']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'unique_id': uniqueId,
    'name': name,
    'mobile': mobile,
    'specialization': specialization,
    'description': description,
    'offline_fee': offlineFee,
    'online_fee': onlineFee,
    'consult_type': consultType,
    'image': image,
    'profile_image': profileImage,
    'status': status,
    'created_on': createdOn,
    'modified_on': modifiedOn,
    'exp': exp,
    'qualification': qualification,
    'open_time': openTime,
    'close_time': closeTime,
  };
}