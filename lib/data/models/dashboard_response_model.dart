import 'package:json_annotation/json_annotation.dart';
part 'dashboard_response_model.g.dart';

@JsonSerializable()
class DashboardResponseModel {
  final int status;
  final String message;
  final DashboardResultModel result;

  DashboardResponseModel({
    required this.status,
    required this.message,
    required this.result,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardResponseModelToJson(this);
}

@JsonSerializable()
class DashboardResultModel {
  @JsonKey(name: 'user_info')
  final UserInfoModel userInfo;
  @JsonKey(name: 'quick_actions')
  final List<QuickActionModel> quickActions;
  @JsonKey(name: 'today_appointments')
  final List<dynamic> todayAppointments;
  @JsonKey(name: 'appointments_count')
  final int appointmentsCount;
  @JsonKey(name: 'today_date')
  final String todayDate;
  @JsonKey(name: 'today_ratings')
  final int todayRatings;
  @JsonKey(name: 'earning_this_month')
  final int earningThisMonth;
  @JsonKey(name: 'patients_this_month')
  final int patientsThisMonth;

  DashboardResultModel({
    required this.userInfo,
    required this.quickActions,
    required this.todayAppointments,
    required this.appointmentsCount,
    required this.todayDate,
    this.todayRatings = 0,
    this.earningThisMonth = 0,
    this.patientsThisMonth = 0,
  });

  factory DashboardResultModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardResultModelFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardResultModelToJson(this);
}

@JsonSerializable()
class UserInfoModel {
  @JsonKey(name: 'doctor_name')
  final String doctorName;
  @JsonKey(name: 'speciality_id')
  final String specialityId;
  final String image;

  UserInfoModel({
    required this.doctorName,
    required this.specialityId,
    required this.image,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserInfoModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoModelToJson(this);
}

@JsonSerializable()
class QuickActionModel {
  final String name;
  final String icon;
  final String route;

  QuickActionModel({
    required this.name,
    required this.icon,
    required this.route,
  });

  factory QuickActionModel.fromJson(Map<String, dynamic> json) =>
      _$QuickActionModelFromJson(json);
  Map<String, dynamic> toJson() => _$QuickActionModelToJson(this);
}