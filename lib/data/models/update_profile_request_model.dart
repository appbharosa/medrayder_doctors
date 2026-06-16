class UpdateProfileRequestModel {
  final String name;
  final int exp;
  final String description;
  final String consultType; // field name matches JSON key exactly (snake_case)
  final int onlineFee;
  final int offlineFee;

  UpdateProfileRequestModel({
    required this.name,
    required this.exp,
    required this.description,
    required this.consultType,
    required this.onlineFee,
    required this.offlineFee,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'exp': exp,
    'description': description,
    'consult_type': consultType,   // ✅ matches API expected key
    'online_fee': onlineFee,       // ✅ matches API expected key
    'offline_fee': offlineFee,     // ✅ matches API expected key
  };
}