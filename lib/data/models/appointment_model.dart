class AppointmentModel {
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
  final String specialityName;
  final String doctorName;
  final String patientImage;
  final String patientName;
  final String patientEmail;
  final String patientGender;
  final String patientDob;
  final String bloodGroup;
  final String qualification;

  AppointmentModel({
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
    required this.specialityName,
    required this.doctorName,
    required this.patientImage,
    required this.patientName,
    required this.patientEmail,
    required this.patientGender,
    required this.patientDob,
    required this.bloodGroup,
    required this.qualification,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? 0,
      bookingId: json['booking_id']?.toString() ?? '',
      consultType: json['consult_type']?.toString() ?? '',
      userId: json['user_id'] ?? 0,
      specialityId: json['speciality_id'] ?? 0,
      doctorId: json['doctor_id'] ?? 0,
      slotId: json['slot_id'] ?? 0,
      time: json['time']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      callStatus: json['call_status'] ?? 0,
      familyMemberId: json['family_member_id'] ?? 0,
      fee: json['fee'] ?? 0,
      consultationFee: json['consultation_fee'] ?? 0,
      couponId: json['coupon_id'] ?? 0,
      couponPercentage: json['coupon_percentage'] ?? 0,
      couponDiscount: json['coupon_discount'] ?? 0,
      specialityName: json['speciality_name']?.toString() ?? '',
      doctorName: json['doctor_name']?.toString() ?? '',
      patientImage: json['patient_image']?.toString() ?? '',
      patientName: json['patient_name']?.toString() ?? '',
      patientEmail: json['patient_email']?.toString() ?? '',
      patientGender: json['patient_gender']?.toString() ?? '',
      patientDob: json['patient_dob']?.toString() ?? '',
      bloodGroup: json['blood_group']?.toString() ?? '',
      qualification: json['qualification']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_id': bookingId,
    'consult_type': consultType,
    'user_id': userId,
    'speciality_id': specialityId,
    'doctor_id': doctorId,
    'slot_id': slotId,
    'time': time,
    'date': date,
    'mobile': mobile,
    'call_status': callStatus,
    'family_member_id': familyMemberId,
    'fee': fee,
    'consultation_fee': consultationFee,
    'coupon_id': couponId,
    'coupon_percentage': couponPercentage,
    'coupon_discount': couponDiscount,
    'speciality_name': specialityName,
    'doctor_name': doctorName,
    'patient_image': patientImage,
    'patient_name': patientName,
    'patient_email': patientEmail,
    'patient_gender': patientGender,
    'patient_dob': patientDob,
    'blood_group': bloodGroup,
    'qualification': qualification,
  };
}