class DoctorProfileEntity {
  final int id;
  final String uniqueId;
  final String name;
  final String mobile;
  final String specialization;
  final String description;
  final int offlineFee;
  final int onlineFee;
  final String consultType;
  final String image;
  final String profileImage;
  final int status;
  final String createdOn;
  final String modifiedOn;

  DoctorProfileEntity({
    required this.id,
    required this.uniqueId,
    required this.name,
    required this.mobile,
    required this.specialization,
    required this.description,
    required this.offlineFee,
    required this.onlineFee,
    required this.consultType,
    required this.image,
    required this.profileImage,
    required this.status,
    required this.createdOn,
    required this.modifiedOn,
  });
}