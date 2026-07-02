
import '../../data/models/prescription_response_model.dart';
import '../entities/prescription_request.dart';


abstract class PrescriptionRepository {
  Future<void> addPrescription(PrescriptionRequest request);
  Future<PrescriptionResponseModel> fetchPrescription(String bookingId, String doctorType);
}