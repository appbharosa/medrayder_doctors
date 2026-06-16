import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_api_service.dart';
import '../models/dashboard_response_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardApiService apiService;

  DashboardRepositoryImpl({required this.apiService});

  @override
  Future<DashboardResponseModel> getDashboard(String type) {
    return apiService.getDashboard(type);
  }
}