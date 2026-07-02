// lib/domain/entities/prescription_request.dart
import 'prescription_medicine.dart';
import 'prescription_test.dart';

class PrescriptionRequest {
  final String bookingId;
  final String doctorType; // "online" or "hospital"
  final String viewType;   // "insert"
  final List<PrescriptionMedicine> medicines;
  final List<PrescriptionTest> tests;
  final String notes;

  PrescriptionRequest({
    required this.bookingId,
    required this.doctorType,
    this.viewType = "insert",
    this.medicines = const [],
    this.tests = const [],
    this.notes = "",
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'booking_id': bookingId,
      'doctor_type': doctorType,
      'view_type': viewType,
      'notes': notes,
    };
    if (medicines.isNotEmpty) {
      map['medicines'] = medicines.map((m) => {
        'medicine': m.medicine,
        'medicine_time': m.medicineTime,
      }).toList();
    }
    if (tests.isNotEmpty) {
      map['tests'] = tests.map((t) => {
        'test': t.test,
        'test_instruction': t.testInstruction,
      }).toList();
    }
    return map;
  }
}