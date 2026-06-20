import 'package:doctors/features/wallet/pages/wallet_debit_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart' as di;
import '../../../core/manager/user_manager.dart';
import '../../../data/models/wallet_response_model.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class WalletHistoryPage extends StatefulWidget {
  const WalletHistoryPage({super.key});

  @override
  State<WalletHistoryPage> createState() => _WalletHistoryPageState();
}

class _WalletHistoryPageState extends State<WalletHistoryPage> {
  late final WalletBloc _bloc;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    _bloc = di.sl<WalletBloc>();
    _fetchHistory();
  }

  void _fetchHistory() {
    final user = UserManager().currentUser;
    if (user != null) {
      _bloc.add(FetchWalletHistory(
        doctorId: user.id,
        type: user.type,
        startDate: _startDateController.text.isNotEmpty ? _startDateController.text : null,
        endDate: _endDateController.text.isNotEmpty ? _endDateController.text : null,
        transactionType: _selectedType == 'all' ? null : _selectedType,
      ));
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff1565C0),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formatted = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        controller.text = formatted;
      });
      _fetchHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Wallet History',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xff1565C0),
          elevation: 0,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_balance_wallet),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WalletDebitPage()),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Filter Section
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _startDateController,
                          readOnly: true,
                          onTap: () => _selectDate(context, _startDateController),
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: const Icon(Icons.calendar_today, color: Color(0xff1565C0)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _endDateController,
                          readOnly: true,
                          onTap: () => _selectDate(context, _endDateController),
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: const Icon(Icons.calendar_today, color: Color(0xff1565C0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Transaction Type',
                      labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'credit', child: Text('Credit')),
                      DropdownMenuItem(value: 'debit', child: Text('Debit')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                      _fetchHistory();
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _fetchHistory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1565C0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Main Content
            Expanded(
              child: BlocConsumer<WalletBloc, WalletState>(
                listener: (context, state) {
                  if (state is WalletError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is WalletHistoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is WalletHistoryLoaded) {
                    return _buildContent(context, state.data);
                  } else if (state is WalletError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 60, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(state.error),
                          ElevatedButton(
                            onPressed: _fetchHistory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1565C0),
                            ),
                            child: const Text('Retry', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WalletResponseModel data) {
    final result = data.result;
    final summary = result.accountSummary;
    final transactions = result.transactions;

    return RefreshIndicator(
      color: const Color(0xff1565C0),
      onRefresh: () async {
        _fetchHistory();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TOP USER CARD
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff1565C0),
                    Color(0xff42A5F5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [

                  Row(
                    children: [

                      /// PROFILE ICON
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),

                      const SizedBox(width: 14),

                      /// USER DETAILS
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              result.userInfo.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  result.userInfo.mobile,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 5),

                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    'Opened : ${result.userInfo.accountOpened}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  /// CURRENT BALANCE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [

                        const Text(
                          "Current Balance",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          '₹${summary.currentBalance}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// SUMMARY TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Wallet Summary",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff222222),
                ),
              ),
            ),

            const SizedBox(height: 14),

            /// SUMMARY CARDS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [

                  Expanded(
                    child: _modernSummaryCard(
                      title: "Credit",
                      value: '₹${summary.totalCredit}',
                      icon: Icons.arrow_downward_rounded,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _modernSummaryCard(
                      title: "Debit",
                      value: '₹${summary.totalDebit}',
                      icon: Icons.arrow_upward_rounded,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _modernSummaryCard(
                title: "Transactions",
                value: '${summary.totalTransactions}',
                icon: Icons.receipt_long_rounded,
                color: Colors.orange,
                fullWidth: true,
              ),
            ),

            const SizedBox(height: 24),

            /// TRANSACTION TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Recent Transactions",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff222222),
                ),
              ),
            ),

            const SizedBox(height: 14),

            /// TRANSACTIONS
            transactions.isEmpty
                ? Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Center(
                child: Column(
                  children: [

                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 70,
                      color: Colors.grey.shade400,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'No Transactions Found',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {

                final txn = transactions[index];
                final bool isCredit = txn.type == 'credit';

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [

                      /// ICON
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: isCredit
                              ? Colors.green.withOpacity(0.12)
                              : Colors.red.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          isCredit
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: isCredit
                              ? Colors.green
                              : Colors.red,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 14),

                      /// DETAILS
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              txn.type.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff222222),
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              txn.description ?? 'Wallet Transaction',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: txn.status.toLowerCase() == 'success'
                                    ? Colors.green.shade50
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                txn.status,
                                style: TextStyle(
                                  color:
                                  txn.status.toLowerCase() == 'success'
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// AMOUNT
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [

                          Text(
                            '${isCredit ? '+' : '-'} ₹${txn.amount}',
                            style: TextStyle(
                              color: isCredit
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            txn.createdAt ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// PAGINATION
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'Page ${result.pagination.currentPage} of ${result.pagination.lastPage}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [

          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _summaryCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}