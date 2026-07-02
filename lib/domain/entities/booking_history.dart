import 'package:equatable/equatable.dart';

class BookingHistory extends Equatable {
  final int id;
  final String bookingId;
  final String consultType;
  final int userId;
  final int specialityId;
  final int doctorId;
  final int slotId;
  final String time;
  final String date;
  final String mobile;
  final int callStatus;
  final int familyMemberId;
  final int fee;
  final int consultationFee;
  final int couponId;
  final int couponPercentage;
  final int couponDiscount;
  final String? specialityName;
  final String doctorName;
  final String? image;
  final String patientName;
  final String email;
  final String gender;
  final String dob;
  final String bloodGroup;
  final List<MedicineDetail> medicines;
  final List<NoteDetail> notes;
  final List<TestDetail> tests;

  const BookingHistory({
    required this.id,
    required this.bookingId,
    required this.consultType,
    required this.userId,
    required this.specialityId,
    required this.doctorId,
    required this.slotId,
    required this.time,
    required this.date,
    required this.mobile,
    required this.callStatus,
    required this.familyMemberId,
    required this.fee,
    required this.consultationFee,
    required this.couponId,
    required this.couponPercentage,
    required this.couponDiscount,
    this.specialityName,
    required this.doctorName,
    this.image,
    required this.patientName,
    required this.email,
    required this.gender,
    required this.dob,
    required this.bloodGroup,
    required this.medicines,
    required this.notes,
    required this.tests,
  });

  factory BookingHistory.fromJson(Map<String, dynamic> json) {
    final medicinesList = (json['medicines'] as List? ?? [])
        .map((m) => MedicineDetail.fromJson(m))
        .toList();
    final notesList = (json['notes'] as List? ?? [])
        .map((n) => NoteDetail.fromJson(n))
        .toList();
    final testsList = (json['tests'] as List? ?? [])
        .map((t) => TestDetail.fromJson(t))
        .toList();

    return BookingHistory(
      id: json['id'] as int,
      bookingId: json['booking_id'] ?? '',
      consultType: json['consult_type'] ?? '',
      userId: json['user_id'] as int? ?? 0,
      specialityId: json['speciality_id'] as int? ?? 0,
      doctorId: json['doctor_id'] as int? ?? 0,
      slotId: json['slot_id'] as int? ?? 0,
      time: json['time'] ?? '',
      date: json['date'] ?? '',
      mobile: json['mobile'] ?? '',
      callStatus: json['call_status'] as int? ?? 0,
      familyMemberId: json['family_member_id'] as int? ?? 0,
      fee: json['fee'] as int? ?? 0,
      consultationFee: json['consultation_fee'] as int? ?? 0,
      couponId: json['coupon_id'] as int? ?? 0,
      couponPercentage: json['coupon_percentage'] as int? ?? 0,
      couponDiscount: json['coupon_discount'] as int? ?? 0,
      specialityName: json['speciality_name'] as String?,
      doctorName: json['doctor_name'] ?? '',
      image: json['image'] as String?,
      patientName: json['patient_name'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      bloodGroup: json['blood_group'] ?? '',
      medicines: medicinesList,
      notes: notesList,
      tests: testsList,
    );
  }

  @override
  List<Object?> get props => [id, bookingId];
}

class MedicineDetail extends Equatable {
  final int id;
  final String bookingId;
  final String medicine;
  final String medicineTime;
  final int slotId;
  final String date;
  final String time;
  final String createdOn;

  const MedicineDetail({
    required this.id,
    required this.bookingId,
    required this.medicine,
    required this.medicineTime,
    required this.slotId,
    required this.date,
    required this.time,
    required this.createdOn,
  });

  factory MedicineDetail.fromJson(Map<String, dynamic> json) {
    return MedicineDetail(
      id: json['id'] as int,
      bookingId: json['booking_id'] ?? '',
      medicine: json['medicine'] ?? '',
      medicineTime: json['medicine_time'] ?? '',
      slotId: json['slot_id'] as int? ?? 0,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      createdOn: json['created_on'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, medicine];
}

class TestDetail extends Equatable {
  final int id;
  final String bookingId;
  final String test;
  final String testInstruction;
  final int slotId;
  final String date;
  final String time;
  final String createdOn;

  const TestDetail({
    required this.id,
    required this.bookingId,
    required this.test,
    required this.testInstruction,
    required this.slotId,
    required this.date,
    required this.time,
    required this.createdOn,
  });

  factory TestDetail.fromJson(Map<String, dynamic> json) {
    return TestDetail(
      id: json['id'] as int,
      bookingId: json['booking_id'] ?? '',
      test: json['test'] ?? '',
      testInstruction: json['test_instruction'] ?? '',
      slotId: json['slot_id'] as int? ?? 0,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      createdOn: json['created_on'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, test];
}

class NoteDetail extends Equatable {
  final int id;
  final String bookingId;
  final String notes;
  final int slotId;
  final String date;
  final String time;
  final String createdOn;

  const NoteDetail({
    required this.id,
    required this.bookingId,
    required this.notes,
    required this.slotId,
    required this.date,
    required this.time,
    required this.createdOn,
  });

  factory NoteDetail.fromJson(Map<String, dynamic> json) {
    return NoteDetail(
      id: json['id'] as int,
      bookingId: json['booking_id'] ?? '',
      notes: json['notes'] ?? '',
      slotId: json['slot_id'] as int? ?? 0,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      createdOn: json['created_on'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, notes];
}