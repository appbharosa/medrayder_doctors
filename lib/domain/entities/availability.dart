
class Availability {
  final int availability; 
  final bool isAvailable;
  final String message;

  Availability({
    required this.availability,
    required this.isAvailable,
    required this.message,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      availability: json['availability'] ?? 0,
      isAvailable: json['is_available'] ?? false,
      message: json['message'] ?? '',
    );
  }
}