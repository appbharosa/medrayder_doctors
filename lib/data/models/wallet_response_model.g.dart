// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletResponseModel _$WalletResponseModelFromJson(Map<String, dynamic> json) =>
    WalletResponseModel(
      status: (json['status'] as num).toInt(),
      message: json['message'] as String,
      result: WalletResult.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WalletResponseModelToJson(
  WalletResponseModel instance,
) => <String, dynamic>{
  'status': instance.status,
  'message': instance.message,
  'result': instance.result,
};

WalletResult _$WalletResultFromJson(Map<String, dynamic> json) => WalletResult(
  userInfo: WalletUserInfoModel.fromJson(
    json['user_info'] as Map<String, dynamic>,
  ),
  accountSummary: WalletAccountSummaryModel.fromJson(
    json['account_summary'] as Map<String, dynamic>,
  ),
  transactions: (json['transactions'] as List<dynamic>)
      .map((e) => WalletTransactionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: WalletPaginationModel.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
  statementPeriod: WalletStatementPeriod.fromJson(
    json['statement_period'] as Map<String, dynamic>,
  ),
  filtersApplied: WalletFiltersApplied.fromJson(
    json['filters_applied'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$WalletResultToJson(WalletResult instance) =>
    <String, dynamic>{
      'user_info': instance.userInfo,
      'account_summary': instance.accountSummary,
      'transactions': instance.transactions,
      'pagination': instance.pagination,
      'statement_period': instance.statementPeriod,
      'filters_applied': instance.filtersApplied,
    };

WalletUserInfoModel _$WalletUserInfoModelFromJson(Map<String, dynamic> json) =>
    WalletUserInfoModel(
      name: json['name'] as String,
      mobile: json['mobile'] as String,
      accountOpened: json['account_opened'] as String,
    );

Map<String, dynamic> _$WalletUserInfoModelToJson(
  WalletUserInfoModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'mobile': instance.mobile,
  'account_opened': instance.accountOpened,
};

WalletAccountSummaryModel _$WalletAccountSummaryModelFromJson(
  Map<String, dynamic> json,
) => WalletAccountSummaryModel(
  currentBalance: (json['current_balance'] as num).toDouble(),
  totalCredit: (json['total_credit'] as num).toDouble(),
  totalDebit: (json['total_debit'] as num).toDouble(),
  netBalance: (json['net_balance'] as num).toDouble(),
  totalTransactions: (json['total_transactions'] as num).toInt(),
  completedTransactions: (json['completed_transactions'] as num).toInt(),
  pendingTransactions: (json['pending_transactions'] as num).toInt(),
);

Map<String, dynamic> _$WalletAccountSummaryModelToJson(
  WalletAccountSummaryModel instance,
) => <String, dynamic>{
  'current_balance': instance.currentBalance,
  'total_credit': instance.totalCredit,
  'total_debit': instance.totalDebit,
  'net_balance': instance.netBalance,
  'total_transactions': instance.totalTransactions,
  'completed_transactions': instance.completedTransactions,
  'pending_transactions': instance.pendingTransactions,
};

WalletTransactionModel _$WalletTransactionModelFromJson(
  Map<String, dynamic> json,
) => WalletTransactionModel(
  id: (json['id'] as num).toInt(),
  reference: json['reference'] as String?,
  amount: (json['amount'] as num).toDouble(),
  type: json['type'] as String,
  status: json['status'] as String,
  description: json['description'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$WalletTransactionModelToJson(
  WalletTransactionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'reference': instance.reference,
  'amount': instance.amount,
  'type': instance.type,
  'status': instance.status,
  'description': instance.description,
  'created_at': instance.createdAt,
};

WalletPaginationModel _$WalletPaginationModelFromJson(
  Map<String, dynamic> json,
) => WalletPaginationModel(
  currentPage: (json['current_page'] as num).toInt(),
  lastPage: (json['last_page'] as num).toInt(),
  perPage: (json['per_page'] as num).toInt(),
  total: (json['total'] as num).toInt(),
  from: (json['from'] as num?)?.toInt(),
  to: (json['to'] as num?)?.toInt(),
);

Map<String, dynamic> _$WalletPaginationModelToJson(
  WalletPaginationModel instance,
) => <String, dynamic>{
  'current_page': instance.currentPage,
  'last_page': instance.lastPage,
  'per_page': instance.perPage,
  'total': instance.total,
  'from': instance.from,
  'to': instance.to,
};

WalletStatementPeriod _$WalletStatementPeriodFromJson(
  Map<String, dynamic> json,
) => WalletStatementPeriod(
  startDate: json['start_date'] as String,
  endDate: json['end_date'] as String,
);

Map<String, dynamic> _$WalletStatementPeriodToJson(
  WalletStatementPeriod instance,
) => <String, dynamic>{
  'start_date': instance.startDate,
  'end_date': instance.endDate,
};

WalletFiltersApplied _$WalletFiltersAppliedFromJson(
  Map<String, dynamic> json,
) => WalletFiltersApplied(transactionType: json['transaction_type'] as String);

Map<String, dynamic> _$WalletFiltersAppliedToJson(
  WalletFiltersApplied instance,
) => <String, dynamic>{'transaction_type': instance.transactionType};
