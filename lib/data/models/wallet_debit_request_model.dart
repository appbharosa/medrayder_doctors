class WalletDebitRequestModel {
  final int doctorId;
  final double amount;
  final String type;

  WalletDebitRequestModel({
    required this.doctorId,
    required this.amount,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'doctor_id': doctorId,
    'amount': amount,
    'type': type,
  };
}