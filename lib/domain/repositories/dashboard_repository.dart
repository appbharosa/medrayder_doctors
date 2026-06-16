import '../../data/models/dashboard_response_model.dart';

abstract class DashboardRepository {
  Future<DashboardResponseModel> getDashboard(String type);
}