import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/prescription_request.dart';
import '../../domain/repositories/prescription_repository.dart';
import '../datasources/prescription_api_service.dart';
import '../models/prescription_response_model.dart';

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  final PrescriptionApiService apiService;

  PrescriptionRepositoryImpl({required this.apiService});

  @override
  Future<void> addPrescription(PrescriptionRequest request) {
    return apiService.addPrescription(request);
  }
  @override
  Future<PrescriptionResponseModel> fetchPrescription(String bookingId, String doctorType) {
    return apiService.fetchPrescription(bookingId: bookingId, doctorType: doctorType);
  }
}