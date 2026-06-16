import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart' as di;
import '../../../core/manager/user_manager.dart';
import '../../../data/models/wallet_debit_request_model.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class WalletDebitPage extends StatefulWidget {
  const WalletDebitPage({super.key});

  @override
  State<WalletDebitPage> createState() => _WalletDebitPageState();
}

class _WalletDebitPageState extends State<WalletDebitPage> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedType = 'offline';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: di.sl<WalletBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Request Debit',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
          ),
          backgroundColor: const Color(0xff1565C0),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocConsumer<WalletBloc, WalletState>(
          listener: (context, state) {
            if (state is WalletDebitSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
              // Reset state and pop
              context.read<WalletBloc>().add(ResetWalletDebitState());
              Navigator.pop(context);
            } else if (state is WalletDebitFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
              // Reset state
              context.read<WalletBloc>().add(ResetWalletDebitState());
            }
          },
          builder: (context, state) {
            final isLoading = state is WalletDebitLoading;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter amount',
                      prefixText: '₹ ',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'offline', child: Text('Offline Doctor')),
                      DropdownMenuItem(value: 'online', child: Text('Online Doctor')),
                    ],
                    onChanged: (value) => setState(() => _selectedType = value!),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                        final amount = double.tryParse(_amountController.text.trim());
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid amount'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        final user = UserManager().currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User not logged in'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        context.read<WalletBloc>().add(
                          RequestWalletDebit(
                            WalletDebitRequestModel(
                              doctorId: user.id,
                              amount: amount,
                              type: _selectedType,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1565C0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Request Debit',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}