class UserEntity {
  final int id;
  final String uniqueId;
  final String phone;
  final String type;
  final String name;
  final String? email;
  final String? image;
  final String accessToken;

  UserEntity({
    required this.id,
    required this.uniqueId,
    required this.phone,
    required this.type,
    required this.name,
    this.email,
    this.image,
    required this.accessToken,
  });
}