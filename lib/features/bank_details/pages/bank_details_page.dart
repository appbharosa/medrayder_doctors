import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart' as di;
import '../../../data/models/bank_detail_model.dart';
import '../bloc/bank_detail_bloc.dart';
import '../bloc/bank_detail_event.dart';
import '../bloc/bank_detail_state.dart';
import 'bank_detail_form_page.dart';




class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  late final BankBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = di.sl<BankBloc>()..add(FetchBankDetails());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Bank Account',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xff1565C0),
          elevation: 0,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: BlocConsumer<BankBloc, BankState>(
            listener: (context, state) {
              if (state is BankOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              } else if (state is BankError) {
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
              if (state is BankLoading && state is! BankLoaded) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is BankLoaded) {
                final List<BankDetailModel> details = state.details;
                if (details.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildDetailsList(context, details);
              } else if (state is BankError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(state.error),
                      ElevatedButton(
                        onPressed: () => context.read<BankBloc>().add(FetchBankDetails()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final state = context.watch<BankBloc>().state;
            final hasDetails = state is BankLoaded && state.details.isNotEmpty;
            return FloatingActionButton.extended(
              onPressed: () => _navigateToForm(context, null),
              backgroundColor: const Color(0xff1565C0),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add Bank Details",
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Bank Details Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Tap the + button to add your bank details'),
        ],
      ),
    );
  }

  Widget _buildDetailsList(BuildContext context, List<BankDetailModel> details) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final detail = details[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      detail.bankName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xff1565C0)),
                      onPressed: () => _navigateToForm(context, detail),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _infoRow('Account Holder', detail.accountName),
                _infoRow('Account Number', detail.accountNumber),
                _infoRow('IFSC Code', detail.ifscCode),
                _infoRow('Branch', detail.branchName),
                _infoRow('Account Type', detail.accountType),
                _infoRow('Type', detail.type),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToForm(BuildContext context, BankDetailModel? existingDetail) {
    final bloc = context.read<BankBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BankDetailFormPage(
          existingDetail: existingDetail,
          bloc: bloc,
        ),
      ),
    ).then((_) {
      bloc.add(FetchBankDetails());
    });
  }
}