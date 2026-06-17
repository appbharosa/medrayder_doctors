class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String? image;
  final String? url;
  final bool isRead;
  final String createdAt;
  final String? updatedAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.image,
    this.url,
    required this.isRead,
    required this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      image: json['image']?.toString(),
      url: json['url']?.toString(),
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'image': image,
    'url': url,
    'is_read': isRead,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}