

class BankDetailModel {
  final int id;
  final String type;
  final int doctorId;
  final String bankName;
  final String branchName;
  final String accountName;
  final String accountNumber;
  final String ifscCode;
  final String? createdAt;
  final String? updatedAt;
  final String accountType;

  BankDetailModel({
    required this.id,
    required this.type,
    required this.doctorId,
    required this.bankName,
    required this.branchName,
    required this.accountName,
    required this.accountNumber,
    required this.ifscCode,
    this.createdAt,
    this.updatedAt,
    required this.accountType,
  });

  // ✅ Manual fromJson with safe null handling
  factory BankDetailModel.fromJson(Map<String, dynamic> json) {
    // Safe converter for numbers (handles null, string, int)
    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return BankDetailModel(
      id: _toInt(json['id']),
      type: json['type']?.toString() ?? '',
      doctorId: _toInt(json['doctor_id']),
      bankName: json['bank_name']?.toString() ?? '',
      branchName: json['branch_name']?.toString() ?? '',
      accountName: json['account_name']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      ifscCode: json['ifsc_code']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      accountType: json['account_type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'doctor_id': doctorId,
    'bank_name': bankName,
    'branch_name': branchName,
    'account_name': accountName,
    'account_number': accountNumber,
    'ifsc_code': ifscCode,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'account_type': accountType,
  };
}