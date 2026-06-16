class UserModel {
  final int id;
  final String uniqueId;
  final String phone;
  final String type;
  final String name;
  final String? email;
  final String? image;
  final String accessToken;

  UserModel({
    required this.id,
    required this.uniqueId,
    required this.phone,
    required this.type,
    required this.name,
    this.email,
    this.image,
    required this.accessToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      uniqueId: json['unique_id'],
      phone: json['phone'].toString(),
      type: json['type'],
      name: json['name'],
      email: json['email'],
      image: json['image'],
      accessToken: json['access_token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'unique_id': uniqueId,
    'phone': phone,
    'type': type,
    'name': name,
    'email': email,
    'image': image,
    'access_token': accessToken,
  };
}