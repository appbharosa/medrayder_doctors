class DashboardEntity {
  final UserInfoEntity userInfo;
  final List<QuickActionEntity> quickActions;
  final List<dynamic> todayAppointments; 
  final int appointmentsCount;
  final String todayDate;

  DashboardEntity({
    required this.userInfo,
    required this.quickActions,
    required this.todayAppointments,
    required this.appointmentsCount,
    required this.todayDate,
  });
}

class UserInfoEntity {
  final String doctorName;
  final String specialityId;
  final String image;

  UserInfoEntity({
    required this.doctorName,
    required this.specialityId,
    required this.image,
  });
}

class QuickActionEntity {
  final String name;
  final String icon;
  final String route;

  QuickActionEntity({
    required this.name,
    required this.icon,
    required this.route,
  });
}