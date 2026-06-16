class WalletUserInfo {
  final String name;
  final String mobile;
  final String accountOpened;

  WalletUserInfo({
    required this.name,
    required this.mobile,
    required this.accountOpened,
  });
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
}

class WalletFilters {
  final String? startDate;
  final String? endDate;
  final String? transactionType;

  WalletFilters({this.startDate, this.endDate, this.transactionType});
}

class WalletData {
  final WalletUserInfo userInfo;
  final WalletAccountSummary accountSummary;
  final List<WalletTransaction> transactions;
  final WalletPagination pagination;
  final WalletFilters filters;

  WalletData({
    required this.userInfo,
    required this.accountSummary,
    required this.transactions,
    required this.pagination,
    required this.filters,
  });
}