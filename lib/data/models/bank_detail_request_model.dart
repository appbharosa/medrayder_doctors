class BankDetailRequestModel {
  final int doctorId;
  final String type;
  final String accountName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String branchName;
  final String accountType;

  BankDetailRequestModel({
    required this.doctorId,
    required this.type,
    required this.accountName,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.branchName,
    required this.accountType,
  });

  Map<String, dynamic> toJson() => {
    'doctor_id': doctorId,
    'type': type,
    'account_name': accountName,
    'account_number': accountNumber,
    'ifsc_code': ifscCode,
    'bank_name': bankName,
    'branch_name': branchName,
    'account_type': accountType,
  };
}