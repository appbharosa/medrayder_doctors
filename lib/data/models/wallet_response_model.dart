import 'package:json_annotation/json_annotation.dart';

part 'wallet_response_model.g.dart';

@JsonSerializable()
class WalletResponseModel {
  final int status;
  final String message;
  final WalletResult result;

  WalletResponseModel({required this.status, required this.message, required this.result});

  factory WalletResponseModel.fromJson(Map<String, dynamic> json) =>
      _$WalletResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$WalletResponseModelToJson(this);
}

@JsonSerializable()
class WalletResult {
  @JsonKey(name: 'user_info')
  final WalletUserInfoModel userInfo;
  @JsonKey(name: 'account_summary')
  final WalletAccountSummaryModel accountSummary;
  final List<WalletTransactionModel> transactions;
  final WalletPaginationModel pagination;
  @JsonKey(name: 'statement_period')
  final WalletStatementPeriod statementPeriod;
  @JsonKey(name: 'filters_applied')
  final WalletFiltersApplied filtersApplied;

  WalletResult({
    required this.userInfo,
    required this.accountSummary,
    required this.transactions,
    required this.pagination,
    required this.statementPeriod,
    required this.filtersApplied,
  });

  factory WalletResult.fromJson(Map<String, dynamic> json) =>
      _$WalletResultFromJson(json);
  Map<String, dynamic> toJson() => _$WalletResultToJson(this);
}

@JsonSerializable()
class WalletUserInfoModel {
  final String name;
  final String mobile;  // ✅ Always String
  @JsonKey(name: 'account_opened')
  final String accountOpened;

  WalletUserInfoModel({
    required this.name,
    required this.mobile,
    required this.accountOpened,
  });

  factory WalletUserInfoModel.fromJson(Map<String, dynamic> json) {
    // Safe conversion for mobile (int or string)
    final mobileValue = json['mobile'];
    final mobileStr = mobileValue?.toString() ?? '';

    return WalletUserInfoModel(
      name: json['name']?.toString() ?? '',
      mobile: mobileStr,
      accountOpened: json['account_opened']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'mobile': mobile,
    'account_opened': accountOpened,
  };
}

@JsonSerializable()
class WalletAccountSummaryModel {
  @JsonKey(name: 'current_balance')
  final double currentBalance;
  @JsonKey(name: 'total_credit')
  final double totalCredit;
  @JsonKey(name: 'total_debit')
  final double totalDebit;
  @JsonKey(name: 'net_balance')
  final double netBalance;
  @JsonKey(name: 'total_transactions')
  final int totalTransactions;
  @JsonKey(name: 'completed_transactions')
  final int completedTransactions;
  @JsonKey(name: 'pending_transactions')
  final int pendingTransactions;

  WalletAccountSummaryModel({
    required this.currentBalance,
    required this.totalCredit,
    required this.totalDebit,
    required this.netBalance,
    required this.totalTransactions,
    required this.completedTransactions,
    required this.pendingTransactions,
  });

  factory WalletAccountSummaryModel.fromJson(Map<String, dynamic> json) {
    // Safe conversion for all numbers (handle int/double)
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return WalletAccountSummaryModel(
      currentBalance: _toDouble(json['current_balance']),
      totalCredit: _toDouble(json['total_credit']),
      totalDebit: _toDouble(json['total_debit']),
      netBalance: _toDouble(json['net_balance']),
      totalTransactions: _toInt(json['total_transactions']),
      completedTransactions: _toInt(json['completed_transactions']),
      pendingTransactions: _toInt(json['pending_transactions']),
    );
  }

  Map<String, dynamic> toJson() => {
    'current_balance': currentBalance,
    'total_credit': totalCredit,
    'total_debit': totalDebit,
    'net_balance': netBalance,
    'total_transactions': totalTransactions,
    'completed_transactions': completedTransactions,
    'pending_transactions': pendingTransactions,
  };
}

@JsonSerializable()
class WalletTransactionModel {
  final int id;
  final String? reference;
  final double amount;
  final String type;
  final String status;
  final String? description;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  WalletTransactionModel({
    required this.id,
    this.reference,
    required this.amount,
    required this.type,
    required this.status,
    this.description,
    this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    // Safe amount parsing
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return WalletTransactionModel(
      id: _toInt(json['id']),
      reference: json['reference']?.toString(),
      amount: _toDouble(json['amount']),
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      description: json['description']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    'amount': amount,
    'type': type,
    'status': status,
    'description': description,
    'created_at': createdAt,
  };
}

@JsonSerializable()
class WalletPaginationModel {
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'last_page')
  final int lastPage;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;
  final int? from;
  final int? to;

  WalletPaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
  });

  factory WalletPaginationModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    return WalletPaginationModel(
      currentPage: _toInt(json['current_page']),
      lastPage: _toInt(json['last_page']),
      perPage: _toInt(json['per_page']),
      total: _toInt(json['total']),
      from: json['from'] != null ? _toInt(json['from']) : null,
      to: json['to'] != null ? _toInt(json['to']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
    'from': from,
    'to': to,
  };
}

@JsonSerializable()
class WalletStatementPeriod {
  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String endDate;

  WalletStatementPeriod({required this.startDate, required this.endDate});

  factory WalletStatementPeriod.fromJson(Map<String, dynamic> json) {
    return WalletStatementPeriod(
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'start_date': startDate,
    'end_date': endDate,
  };
}

@JsonSerializable()
class WalletFiltersApplied {
  @JsonKey(name: 'transaction_type')
  final String transactionType;

  WalletFiltersApplied({required this.transactionType});

  factory WalletFiltersApplied.fromJson(Map<String, dynamic> json) {
    return WalletFiltersApplied(
      transactionType: json['transaction_type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'transaction_type': transactionType,
  };
}