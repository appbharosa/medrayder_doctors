
import '../../domain/entities/availability.dart';
import '../../domain/repositories/availability_repository.dart';
import '../datasources/availability_api_service.dart';

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  final AvailabilityApiService apiService;

  AvailabilityRepositoryImpl(this.apiService);

  @override
  Future<Availability> updateAvailability(String type) async {
    final json = await apiService.updateAvailability(type);
    return Availability.fromJson(json['result']);
  }
}