import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/manager/user_manager.dart';
import '../bloc/bank_detail_bloc.dart';
import '../bloc/bank_detail_event.dart';
import '../../../data/models/bank_detail_model.dart';
import '../../../data/models/bank_detail_request_model.dart';
import '../bloc/bank_detail_state.dart';


class BankDetailFormPage extends StatefulWidget {
  final BankDetailModel? existingDetail;
  final BankBloc? bloc;

  const BankDetailFormPage({
    super.key,
    this.existingDetail,
    this.bloc,
  });

  @override
  State<BankDetailFormPage> createState() => _BankDetailFormPageState();
}

class _BankDetailFormPageState extends State<BankDetailFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  String _accountType = 'savings';
  final List<String> _accountTypes = ['savings', 'current',];

  @override
  void initState() {
    super.initState();
    if (widget.existingDetail != null) {
      _accountNameController.text = widget.existingDetail!.accountName;
      _accountNumberController.text = widget.existingDetail!.accountNumber;
      _ifscController.text = widget.existingDetail!.ifscCode;
      _bankNameController.text = widget.existingDetail!.bankName;
      _branchNameController.text = widget.existingDetail!.branchName;
      _accountType = widget.existingDetail!.accountType;
    }
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = widget.bloc;
    if (bloc == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: const Color(0xff1565C0),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Bank Bloc not provided')),
      );
    }

    return BlocProvider.value(
      value: bloc,
      child: Builder(
        builder: (context) => _buildForm(context),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final isEdit = widget.existingDetail != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Update Bank Details' : 'Add Bank Details',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xff1565C0),
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<BankBloc, BankState>(
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
            Navigator.pop(context, true);
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _accountNameController,
                        label: 'Account Holder Name',
                        hint: 'Enter account holder name',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _accountNumberController,
                        label: 'Account Number',
                        hint: 'Enter account number',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _ifscController,
                        label: 'IFSC Code',
                        hint: 'Enter IFSC code',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _bankNameController,
                        label: 'Bank Name',
                        hint: 'Enter bank name',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _branchNameController,
                        label: 'Branch Name',
                        hint: 'Enter branch name',
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _accountType,
                        decoration: InputDecoration(
                          labelText: 'Account Type',
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        items: _accountTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type.toUpperCase(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _accountType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final user = UserManager().currentUser;
                        final request = BankDetailRequestModel(
                          doctorId: user?.id ?? 0,
                          type: user?.type ?? 'offline',
                          accountName: _accountNameController.text.trim(),
                          accountNumber: _accountNumberController.text.trim(),
                          ifscCode: _ifscController.text.trim(),
                          bankName: _bankNameController.text.trim(),
                          branchName: _branchNameController.text.trim(),
                          accountType: _accountType,
                        );
                        if (isEdit) {
                          context.read<BankBloc>().add(
                            UpdateBankDetail(widget.existingDetail!.id, request),
                          );
                        } else {
                          context.read<BankBloc>().add(
                            AddBankDetail(request),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1565C0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isEdit ? 'Update' : 'Save',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}