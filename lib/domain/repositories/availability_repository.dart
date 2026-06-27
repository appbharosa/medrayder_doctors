
import '../entities/availability.dart';

abstract class AvailabilityRepository {
  Future<Availability> updateAvailability(String type); // type: "online" or "offline"
}