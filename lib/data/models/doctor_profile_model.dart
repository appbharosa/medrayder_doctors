import 'package:json_annotation/json_annotation.dart';

part 'doctor_profile_model.g.dart';

@JsonSerializable()
class DoctorProfileModel {
  final int id;
  @JsonKey(name: 'unique_id')
  final String uniqueId;
  final String name;
  final String mobile; // will be parsed from int
  final String specialization;
  final String description;
  @JsonKey(name: 'offline_fee')
  final int offlineFee;
  @JsonKey(name: 'online_fee')
  final int onlineFee;
  @JsonKey(name: 'consult_type')
  final String consultType;
  final String image;
  @JsonKey(name: 'profile_image')
  final String profileImage;
  final int status;
  @JsonKey(name: 'created_on')
  final String createdOn;
  @JsonKey(name: 'modified_on')
  final String modifiedOn;

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
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    // Manually parse mobile as String to handle int
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
  };
}