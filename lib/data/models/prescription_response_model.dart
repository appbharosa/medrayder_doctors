import 'package:equatable/equatable.dart';

class PrescriptionResponseModel extends Equatable {
  final String doctorType;
  final List<MedicineDetail> medicines;
  final List<TestDetail> tests;
  final List<NoteDetail> notes;

  const PrescriptionResponseModel({
    required this.doctorType,
    required this.medicines,
    required this.tests,
    required this.notes,
  });

  factory PrescriptionResponseModel.fromJson(Map<String, dynamic> json) {
    final medicinesList = (json['medicines'] as List? ?? [])
        .map((m) => MedicineDetail.fromJson(m))
        .toList();
    final testsList = (json['tests'] as List? ?? [])
        .map((t) => TestDetail.fromJson(t))
        .toList();
    final notesList = (json['notes'] as List? ?? [])
        .map((n) => NoteDetail.fromJson(n))
        .toList();
    return PrescriptionResponseModel(
      doctorType: json['doctor_type'] ?? '',
      medicines: medicinesList,
      tests: testsList,
      notes: notesList,
    );
  }

  @override
  List<Object?> get props => [doctorType, medicines, tests, notes];
}

class MedicineDetail extends Equatable {
  final int id;
  final String medicine;
  final String medicineTime;
  final String date;
  final String time;

  const MedicineDetail({
    required this.id,
    required this.medicine,
    required this.medicineTime,
    required this.date,
    required this.time,
  });

  factory MedicineDetail.fromJson(Map<String, dynamic> json) {
    return MedicineDetail(
      id: json['id'] as int,
      medicine: json['medicine'] ?? '',
      medicineTime: json['medicine_time'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, medicine];
}

class TestDetail extends Equatable {
  final int id;
  final String test;
  final String testInstruction;
  final String date;
  final String time;

  const TestDetail({
    required this.id,
    required this.test,
    required this.testInstruction,
    required this.date,
    required this.time,
  });

  factory TestDetail.fromJson(Map<String, dynamic> json) {
    return TestDetail(
      id: json['id'] as int,
      test: json['test'] ?? '',
      testInstruction: json['test_instruction'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, test];
}

class NoteDetail extends Equatable {
  final int id;
  final String notes;
  final String date;
  final String time;

  const NoteDetail({
    required this.id,
    required this.notes,
    required this.date,
    required this.time,
  });

  factory NoteDetail.fromJson(Map<String, dynamic> json) {
    return NoteDetail(
      id: json['id'] as int,
      notes: json['notes'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, notes];
}