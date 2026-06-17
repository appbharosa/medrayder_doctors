class WalletResponseModel {
  final int status;
  final String message;
  final WalletResult result;

  WalletResponseModel({
    required this.status,
    required this.message,
    required this.result,
  });

  factory WalletResponseModel.fromJson(Map<String, dynamic> json) {
    return WalletResponseModel(
      status: _toInt(json['status']),
      message: _toString(json['message']),
      result: WalletResult.fromJson(json['result'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'result': result.toJson(),
  };

  // Utility methods for safe type conversion
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String _toString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}

class WalletResult {
  final WalletUserInfo userInfo;
  final WalletAccountSummary accountSummary;
  final List<WalletTransaction> transactions;
  final WalletPagination pagination;
  final WalletStatementPeriod statementPeriod;
  final WalletFiltersApplied filtersApplied;

  WalletResult({
    required this.userInfo,
    required this.accountSummary,
    required this.transactions,
    required this.pagination,
    required this.statementPeriod,
    required this.filtersApplied,
  });

  factory WalletResult.fromJson(Map<String, dynamic> json) {
    dynamic filtersData = json['filters_applied'];
    WalletFiltersApplied filters;
    if (filtersData is Map<String, dynamic>) {
      filters = WalletFiltersApplied.fromJson(filtersData);
    } else {
      filters = WalletFiltersApplied(transactionType: 'all'); // fallback
    }

    return WalletResult(
      userInfo: WalletUserInfo.fromJson(json['user_info'] ?? {}),
      accountSummary: WalletAccountSummary.fromJson(json['account_summary'] ?? {}),
      transactions: _parseTransactions(json['transactions']),
      pagination: WalletPagination.fromJson(json['pagination'] ?? {}),
      statementPeriod: WalletStatementPeriod.fromJson(json['statement_period'] ?? {}),
      filtersApplied: filters,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_info': userInfo.toJson(),
    'account_summary': accountSummary.toJson(),
    'transactions': transactions.map((e) => e.toJson()).toList(),
    'pagination': pagination.toJson(),
    'statement_period': statementPeriod.toJson(),
    'filters_applied': filtersApplied.toJson(),
  };

  static List<WalletTransaction> _parseTransactions(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data
          .where((item) => item is Map<String, dynamic>)
          .map((item) => WalletTransaction.fromJson(item))
          .toList();
    }
    return [];
  }
}

class WalletUserInfo {
  final String name;
  final String mobile;
  final String accountOpened;

  WalletUserInfo({
    required this.name,
    required this.mobile,
    required this.accountOpened,
  });

  factory WalletUserInfo.fromJson(Map<String, dynamic> json) {
    return WalletUserInfo(
      name: _toString(json['name']),
      mobile: _toString(json['mobile']),
      accountOpened: _toString(json['account_opened']),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'mobile': mobile,
    'account_opened': accountOpened,
  };

  static String _toString(dynamic value) => value?.toString() ?? '';
}

class WalletAccountSummary {
  final double currentBalance;
  final double totalCredit;
  final double totalDebit;
  final double netBalance;
  final int totalTransactions;
  final int completedTransactions;
  final int pendingTransactions;

  WalletAccountSummary({
    required this.currentBalance,
    required this.totalCredit,
    required this.totalDebit,
    required this.netBalance,
    required this.totalTransactions,
    required this.completedTransactions,
    required this.pendingTransactions,
  });

  factory WalletAccountSummary.fromJson(Map<String, dynamic> json) {
    return WalletAccountSummary(
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

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class WalletTransaction {
  final int id;
  final String? reference;
  final double amount;
  final String type;
  final String status;
  final String? description;
  final String? createdAt;

  WalletTransaction({
    required this.id,
    this.reference,
    required this.amount,
    required this.type,
    required this.status,
    this.description,
    this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: _toInt(json['id']),
      reference: _toStringOrNull(json['reference']),
      amount: _toDouble(json['amount']),
      type: _toString(json['type']),
      status: _toString(json['status']),
      description: _toStringOrNull(json['description']),
      createdAt: _toStringOrNull(json['created_at']),
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

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String _toString(dynamic value) => value?.toString() ?? '';
  static String? _toStringOrNull(dynamic value) => value?.toString();
}

class WalletPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;

  WalletPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
  });

  factory WalletPagination.fromJson(Map<String, dynamic> json) {
    return WalletPagination(
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

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class WalletStatementPeriod {
  final String startDate;
  final String endDate;

  WalletStatementPeriod({required this.startDate, required this.endDate});

  factory WalletStatementPeriod.fromJson(Map<String, dynamic> json) {
    return WalletStatementPeriod(
      startDate: _toString(json['start_date']),
      endDate: _toString(json['end_date']),
    );
  }

  Map<String, dynamic> toJson() => {
    'start_date': startDate,
    'end_date': endDate,
  };

  static String _toString(dynamic value) => value?.toString() ?? '';
}

class WalletFiltersApplied {
  final String transactionType;

  WalletFiltersApplied({required this.transactionType});

  factory WalletFiltersApplied.fromJson(Map<String, dynamic> json) {
    return WalletFiltersApplied(
      transactionType: _toString(json['transaction_type']),
    );
  }

  Map<String, dynamic> toJson() => {
    'transaction_type': transactionType,
  };

  static String _toString(dynamic value) => value?.toString() ?? '';
}