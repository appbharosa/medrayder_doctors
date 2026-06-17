import 'appointment_model.dart';

class AppointmentResponseModel {
  final int status;
  final String message;
  final List<AppointmentModel> data;
  final AppointmentPagination pagination;

  AppointmentResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory AppointmentResponseModel.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List? ?? [];
    return AppointmentResponseModel(
      status: json['status'] ?? 0,
      message: json['message']?.toString() ?? '',
      data: dataList
          .where((item) => item is Map<String, dynamic>)
          .map((item) => AppointmentModel.fromJson(item))
          .toList(),
      pagination: AppointmentPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class AppointmentPagination {
  final int total;
  final int limit;
  final int offset;
  final int currentPage;
  final int totalPages;

  AppointmentPagination({
    required this.total,
    required this.limit,
    required this.offset,
    required this.currentPage,
    required this.totalPages,
  });

  factory AppointmentPagination.fromJson(Map<String, dynamic> json) {
    return AppointmentPagination(
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 10,
      offset: json['offset'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 0,
    );
  }
}