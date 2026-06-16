// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardResponseModel _$DashboardResponseModelFromJson(
  Map<String, dynamic> json,
) => DashboardResponseModel(
  status: (json['status'] as num).toInt(),
  message: json['message'] as String,
  result: DashboardResultModel.fromJson(json['result'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DashboardResponseModelToJson(
  DashboardResponseModel instance,
) => <String, dynamic>{
  'status': instance.status,
  'message': instance.message,
  'result': instance.result,
};

DashboardResultModel _$DashboardResultModelFromJson(
  Map<String, dynamic> json,
) => DashboardResultModel(
  userInfo: UserInfoModel.fromJson(json['user_info'] as Map<String, dynamic>),
  quickActions: (json['quick_actions'] as List<dynamic>)
      .map((e) => QuickActionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  todayAppointments: json['today_appointments'] as List<dynamic>,
  appointmentsCount: (json['appointments_count'] as num).toInt(),
  todayDate: json['today_date'] as String,
);

Map<String, dynamic> _$DashboardResultModelToJson(
  DashboardResultModel instance,
) => <String, dynamic>{
  'user_info': instance.userInfo,
  'quick_actions': instance.quickActions,
  'today_appointments': instance.todayAppointments,
  'appointments_count': instance.appointmentsCount,
  'today_date': instance.todayDate,
};

UserInfoModel _$UserInfoModelFromJson(Map<String, dynamic> json) =>
    UserInfoModel(
      doctorName: json['doctor_name'] as String,
      specialityId: json['speciality_id'] as String,
      image: json['image'] as String,
    );

Map<String, dynamic> _$UserInfoModelToJson(UserInfoModel instance) =>
    <String, dynamic>{
      'doctor_name': instance.doctorName,
      'speciality_id': instance.specialityId,
      'image': instance.image,
    };

QuickActionModel _$QuickActionModelFromJson(Map<String, dynamic> json) =>
    QuickActionModel(
      name: json['name'] as String,
      icon: json['icon'] as String,
      route: json['route'] as String,
    );

Map<String, dynamic> _$QuickActionModelToJson(QuickActionModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'icon': instance.icon,
      'route': instance.route,
    };
